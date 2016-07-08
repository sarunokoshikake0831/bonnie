'use strict';

const log4js = require('log4js');
const util   = require('../util');

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
        const msg_pfx = '[v1/register] '
        let   report  = req.body;

        report.author      = req.session.user.account;
        report.is_reported = false;
        report.is_dirty    = false;

        db.collection('etc').findOneAndUpdate(
            { purpose: 'number management' },
            { '$inc': { number: 1 } }
        ).then(result => {
            report.number  = result.value.number.toString();
            report.version = 0;
            return db.collection('reports').insertOne(report);
        }).then(result => {
            db.close();
            res.status(201).send({ number: report.number });

            const msg = `registered report by ${req.session.user.account}.`;
            log_info.info(`${msg_pfx} ${msg}`);
        }).catch(err => {
            db.close();

            res.sendStatus(500);
            log_warn.warn(err);

            const msg = 'failed to access collection.';
            log_warn.warn(`${msg_pfx} ${msg}`);
        });
    });
};
