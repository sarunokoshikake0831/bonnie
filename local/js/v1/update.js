'use strict';

const ObjectID = require('mongodb').ObjectID;
const log4js   = require('log4js');
const util     = require('../util');

const log_info = log4js.getLogger('info');
const log_warn = log4js.getLogger('warning');
const log_crit = log4js.getLogger('critical');

module.exports = (req, res) => {
    const status = util.is_authorized(req);

    if (status != 200) {
        res.sendStatus(status);
        return;
    }

    util.query(db => {
        const report_id = req.params.id;
        const msg_pfx   = '[v1/update]'

        let data = { version: req.body.version + 1 };

        Object.keys(req.body).forEach(key => {
            if (key != 'version') {
                data[key] = req.body[key]
            }
        });


        /*
         * バージョン番号が一致しないレポートは更新しない。
         * つまり、先に誰かが更新してしまったレポートを更新することは
         * できない。
         * 当然、既に消去されてしまったレポートも更新できない。
         */
        db.collection('reports').findOneAndUpdate(
            {
                _id:     new ObjectID(report_id),
                version: req.body.version
            },
            { '$set': data }
        ).then(result => {
            db.close();

            if (result.value == null) {
                res.sendStatus(409);

                const msg = msg_pfx +
                            ` supressed to update report: ${report_id},` +
                            ' because already updated.';

                log_info.inf(msg);
            } else {
                res.sendStatus(200);
                log_info.info(`${msg_pfx} report updated: ${report_id}`);
            }
        }).catch(err => {
            db.close();

            res.sendStatus(500);
            log_warn.warn(err);

            const msg = `${msg_pfx} failed to access "reports" collection`;

            log_warn.warn(msg);
        });
    });
};
