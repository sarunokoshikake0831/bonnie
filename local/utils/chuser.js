#!/usr/bin/env node

const util = require('../js/util');

function usage() {
    console.log('usage: chuser.js -[rpak] account');
}

if (process.argv.length != 4) {
    usage();
    return;
}

let update = {};

switch (process.argv[2]) {
case '-r':
    // 一般ユーザ (restricted) へ変更
    update.authority = 'restricted';
    break;
case '-p':
    // 特権ユーザ (privileged) へ変更
    update.authority = 'privileged';
    break;
case '-a':
    // ユーザを復活 (anabiosis)
    update.is_alive = true;
    break;
case '-k':
    // ユーザを消去 (kill、実際に消すのではなく、ログイン対象外とするだけ)
    update.is_alive = false;
    break;
default:
    usage();
    return;
}

util.query(db => {
    db.collection('users').updateOne(
        { account: process.argv[3] },
        { $set:    update  }
    ).then(result => {
        db.close();
        console.log('succeeded.');
    }).catch(err => {
        db.close();
        console.log('failed (is account correct?).');
    });
});
