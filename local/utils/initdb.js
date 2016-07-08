db.users.createIndex({ account: 1 }, { unique: true });
db.etc.insert({
    purpose: 'number management',
    number:  1
});
