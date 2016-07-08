'use strict';

const log4js = require('log4js');
const util   = require('../util');

const log_info = log4js.getLogger('info');
const log_warn = log4js.getLogger('warning');
const log_crit = log4js.getLogger('critical');


/*
 * インシデントとトラブル共通の検索条件
 */
function generate_common_condition(req) {
    let condition = [];


    /*
     * restricted なユーザは自分の報告したレポートのみ検索対象
     */
    if (req.session.user.authority === 'restricted') {
        condition.push({ author: req.session.user.account });
    }


    /*
     * レポート番号
     */
    if (req.query.number != '') {
        condition.push({ number: new RegExp(req.query.number) });
    }

    /*
     * 発生日
     */
    const date = req.query.date;

    if (date.from != '') {
        condition.push({ occurrence_date: { '$gte': date.from } });
    }

    if (date.to != '') {
        condition.push({ occurrence_date: { '$lte': date.to } });
    }


    /*
     * 状態
     */

    let condition_state = [];

    if (req.query.state.unreported === 'true') {
        condition_state.push({ is_reported: false });
    }

    if (req.query.state.reported === 'true') {
        condition_state.push({ '$and': [
            { is_reported: true  },
            { is_dirty:    false }
        ] });
    }

    if (req.query.state.dirty === 'true') {
        condition_state.push({ is_dirty: true });
    }

    if (condition_state.length > 0) {
        condition.push({ '$or': condition_state });
    }


    /*
     * テキスト検索
     */
    if (req.query.keyword != '') {
        const regex = new RegExp(req.query.keyword);

        condition.push({ '$or': [
            { title:  regex },
            { detail: regex },
            { cause:  regex },
            { consideration:  regex },
            { countermeasure: regex }
        ] });
    }

    return condition;
}


/*
 * 共通の検索条件に、インシデント固有の条件を追加する。
 * 既存のオブジェクトに追加するのではなく、
 * 新たにオブジェクトを作成して返す (つまり共有の検索条件は変更されない)。
 */
function add_incident_condition(req, orig) {
    let condition = [];

    orig.forEach(o => { condition.push(o) });

    let condition_event0 = [];

    Object.keys(req.query.event0).forEach(key => {
        if (req.query.event0[key] === 'true') {
            condition_event0.push({ event0: key });
        }
    });

    if (condition_event0.length > 0) {
        condition.push({ '$or': condition_event0 });
    }

    let condition_event1 = [];

    Object.keys(req.query.event1).forEach(key => {
        if (req.query.event1[key] === 'true') {
            condition_event1.push({ event1: key });
        }
    });

    if (condition_event1.length > 0) {
        condition.push({ '$or': condition_event1 });
    }

    return condition;
}

module.exports = (req, res) => {
    const status = util.is_authorized(req);

    if (status != 200) {
        res.sendStatus(status);
        return;
    }

    util.query(db => {
        let common_condition = generate_common_condition(req);
        let selector;


        /*
         * インシデントには事象内容 1/2 があるが、トラブルには無い。
         * この違いを手軽に吸収するために、それぞれで独立の検索条件を作成
         * することにした。
         * 両レポートが検索対象の場合、それぞれの検索条件を or で繋げば
         * いっちょあがり。
         * 実に安直。
         */
        const type = req.query.type;

        if (type.incident === 'true' && type.trouble === 'false') {
            let i = add_incident_condition(req, common_condition);
            i.push({ report_type: 'incident' });

            selector = { '$and': i };
        } else if (type.incident === 'false' && type.trouble === 'true') {
            let t = common_condition;
            t.push({ report_type: 'trouble'  });

            selector = { '$and': t };
        } else {
            let i = add_incident_condition(req, common_condition);
            let t = common_condition;

            i.push({ report_type: 'incident' });
            t.push({ report_type: 'trouble'  });

            selector = { '$or': [
                { '$and': i },
                { '$and': t }
            ]};
        }

        db.collection('reports').find(selector).toArray().then(reports => {
            db.close();

            if (reports.length < 1000) {
                res.json({ reports: reports });
            } else {
                res.sendStatus(400);
            }
        }).catch(err => {
            db.close();

            res.sendStatus(500);
            log_warn.warn(err);

            const msg = '[v1/search] ' +
                        'failed to access "reports" collection.';

            log_warn.warn(msg);
        });
    });
};
