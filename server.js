
'use strict';

process.title = 'voting-booth-server';

const FirebaseTokenServer = require('./tokenserver/tokenserver.js');

const PORT        = 4201;
const ADDR        = '0.0.0.0';
const HOST        = (ADDR === '0.0.0.0' ? 'localhost' : ADDR);
const PROTO       = 'http:';
const express     = require('express');
const webserver   = express();
const tokenserver = new FirebaseTokenServer(webserver);

/*
webserver.use('/pokeart', (req, res, next) => {
    const num = Math.floor(Math.random() * 700 + 100);
    res.sendFile(`dist/pokeart/${num}.png`, { root: __dirname });
});
*/

webserver.use('/pokeart', (req, res, next) => {
    setTimeout(function () {
        res.sendFile('/dist' + req.originalUrl, { root: __dirname });
    }, 1000);
});

webserver.use(express.static('dist'));

webserver.listen(PORT, ADDR, function () {
    console.log(
        `Server is listening on ${PROTO}//${HOST}:${PORT}`,
        (ADDR === '0.0.0.0' ? '(all interfaces)' : ''));
}).on('error', function (err) {
    console.log(`Unable to listen on ${ADDR}:${PORT} : ${err.code}`);
});

