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

    util.query( (db) => {
        const msg_pfx = '[v1/update] '
        let   report  = req.body;

        let   report_id = req.params.id;

        console.log(`report_id = ${reporet_id}`);
    });
};
