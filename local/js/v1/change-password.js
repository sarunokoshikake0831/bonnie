'use strict';

const compareSync = require('bcrypt').compareSync;
const hashSync    = require('bcrypt').hashSync;
const genSaltSync = require('bcrypt').genSaltSync;
const log4js      = require('log4js');
const util        = require('../util');

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
        const account      = req.params.account;
        const old_password = req.body.old_password;
        const new_password = req.body.new_password;
        const msg_pfx      = '[v1/password]'

        db.collection('users').find({
            is_alive: true,
            account:  account
        }).limit(1).next().then(user => {
            if (user != null && compareSync(old_password, user.hash) ) {
                const hash = hashSync(new_password, genSaltSync() );

                return db.collection('users').updateOne(
                    { account: account },
                    { $set: { hash: hash } }
                );
            } else {
                return Promise.resolve(null);
            }
        }).catch(err => {
            db.close();

            res.sendStatus(500);
            log_warn.warn(err);

            const msg = `${msg_pfx} failed to access "users" collection.`;

            log_warn.warn(msg);
        }).then(result => {
            db.close();

            if (result == null) {
                res.sendStatus(403);
                const msg = msg_pfx + 
                            ` failed to update ${account}'s password.`;

                log_info.info(msg);
                
            } else {
                res.sendStatus(201);
                log_info.inf(`${msg_pfx} ${account}'s password updated.`);
            }
        });
    });
};
