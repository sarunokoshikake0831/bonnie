'use strict';

const mongodb  = require('mongodb').MongoClient;
const ObjectID = require('mongodb').ObjectID;
const moment   = require('moment');
const log4js   = require('log4js');

const log_info = log4js.getLogger('info');
const log_warn = log4js.getLogger('warning');
const log_crit = log4js.getLogger('ctitical');

module.exports = {
    /*
     * DB への接続
     */
    query(callback) {
        let result;

        mongodb.connect('mongodb://localhost:27017/bonnie', (err, db) => {
            if (err != null) {
                log_warn.warn(err);
                log_warn.warn('[util.query] cannot connect with MongoDB.');
            } else {
                callback(db);
            }
        });
    },


    /*
     * セッションが認証されているかをテストして、
     * 結果を HTTP のステータスコードで返す。
     */
    is_authorized(req) {
        const header_authorization = req.get('Authorization');

        if (header_authorization == null) {
            return 400;
        }

        const match = header_authorization.match(/^Bearer\s+(\S+)$/);

        if (match == null || match[1] != req.session.access_token) {
            return 401;
        }

        return 200;
    }
};
