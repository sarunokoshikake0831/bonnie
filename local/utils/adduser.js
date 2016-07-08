#!/usr/bin/env node

const bcrypt     = require('bcrypt');
const util       = require('../js/util');

function usage() {
    console.log('usage: adduser.js -[rp] account passpword');
}

if (process.argv.length != 5) {
    usage();
    return;
}

let authority;

switch (process.argv[2]) {
case '-r':
    authority = 'restricted';
    break;
case '-p':
    authority = 'privileged';
    break;
default:
    usage();
    return;
}

const account  = process.argv[3];
const password = process.argv[4];
const hash     = bcrypt.hashSync(password, bcrypt.genSaltSync() );

if (bcrypt.compareSync(password, hash) ) {
    util.query(db => {
        db.collection('users').insertOne({
            account:   account,
            hash:      hash,
            authority: authority,
            is_alive:  true
        }).then(result => {
            db.close();
            console.log('added.');
        }).catch(err => {
            db.close();
            console.log(`"${account}" already exists.`);
        });
    });
} else {
    console.log('OOPS! hash does NOT match password input.');
}
