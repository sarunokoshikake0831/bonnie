'use strict';

const mongodb  = require('mongodb').MongoClient;
const ObjectID = require('mongodb').ObjectID;
const moment   = require('moment');
const log4js   = require('log4js');

const log_info = log4js.getLogger('info');
const log_warn = log4js.getLogger('warning');
const log_crit = log4js.getLogger('ctitical');

module.exports = {
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
    },

    uniq(array, eq) {
        function exists(x, a) {
            return a.filter( (y) => eq(x, y) ).length != 0;
        }
                                                                 
        function iter(rest, ans) {
            if (rest.length < 1) {
                return ans;
            } else {   
                const car = rest[0];
                const cdr = rest.slice(1);

                if (exists(car, ans) ) {
                    return iter(cdr, ans);
                } else {         
                    return iter(cdr, ans.concat(car) );
                }
            }
        }

        if (array.length < 2) {
            return array;
        } else {                           
            return iter(array.slice(1), array.slice(0, 1) );
        }
    },
};
