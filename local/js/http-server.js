'use strict';

const express     = require('express');
const session     = require('express-session');
const https       = require('https');
const fs          = require('fs');
const bodyParser  = require('body-parser');
const log4js      = require('log4js');

log4js.configure({
    appenders: [
        {
            type:     'file',
            category: 'info',
            filename: 'local/log/info.log'
        },
        {
            type:     'file',
            category: 'warning',
            filename: 'local/log/warning.log'
        },
        {
            type:     'file',
            category: 'critical',
            filename: 'local/log/critical.log'
        }
    ]
});

const app = express();

app.use(session({
    secret:            'keyboard cat',
    resave:            false,
    saveUninitialized: false,
    cookie:            { secure: true }
}) );

app.use(express.static('public') );
app.use(bodyParser.json() );
app.use(bodyParser.urlencoded({ extended: true }) );

const handlers = {
    v1: {
        oauth2:   require('./v1/oauth2'),
        register: require('./v1/register'),
        search:   require('./v1/search'),
    },
}

function route(name) {
    return function(req, res) {
        handlers[req.params.ver][name](req, res);
    }
}

app.post('/:ver/oauth2/token', route('oauth2') );
app.post('/:ver/reports',      route('register') );

app.get('/:ver/reports', route('search') );

https.createServer({
    key:  fs.readFileSync('local/certs/key.pem'),
    cert: fs.readFileSync('local/certs/cert.pem')
}, app).listen(443);
