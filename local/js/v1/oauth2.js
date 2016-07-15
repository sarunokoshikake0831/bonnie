'use strict';


/*
 * 疑似 OAuth2 認証、つまり手抜き実装。
 * アカウントとパスワードで認証したら、access_token を返すだけ。
 * grant_type は見てないし、Basic 認証で client_id / client_secret も検証
 * しないし、アクセストークンのタイプとか有効期限とか更新用トークンとかも
 * 返さない。
 */
const compareSync = require('bcrypt').compareSync;
const log4js      = require('log4js');
const util        = require('../util');

const log_info = log4js.getLogger('info');
const log_warn = log4js.getLogger('warning');
const log_crit = log4js.getLogger('critical');

function generate_token() {
    const chars = 'abcdefghijklmnopqrstuvwxyz' +
                  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
                  '0123456789-._~+/';

    const len = 16 + Math.floor(Math.random() * 16);

    let token = '';

    for (let i = 0; i < len; i++) {
        token += chars[Math.floor(Math.random() * chars.length)];
    }

    for (let j = 0; j < Math.floor(Math.random() * 8); j++) {
        token += '=';
    }

    return token;
}

module.exports = (req, res) => {
    const account  = req.body.account;
    const password = req.body.password;

    util.query(db => {
        db.collection('users').find({
            is_alive: true,
            account:  account
        }).limit(1).next().then(user => {
            db.close();

            if (user != null && compareSync(password, user.hash) ) {
                const access_token = generate_token();

                req.session.user         = user;
                req.session.access_token = access_token;

                res.json({
                    access_token: access_token,
                    user: {
                        account:   user.account,
                        authority: user.authority
                    }
                });
                log_info.info(`${account} logged in.`);
            } else {
                res.sendStatus(401);
                log_info.info(`${account} login failed.`);
            }
        }).catch(err => {
            db.close();

            res.sendStatus(500);
            log_warn.warn(err);

            const msg = '[v1/oauth2] ' +
                        'failed to access "users" collection.';

            log_warn.warn(msg);
        });
    });
};
