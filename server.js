
'use strict';

process.title = 'voting-booth-server';

const FirebaseTokenServer = require('./tokenserver/tokenserver.js');

const PORT        = 4201;
const ADDR        = '0.0.0.0';
const express     = require('express');
const webserver   = express();
const tokenserver = new FirebaseTokenServer(webserver);

webserver.use(express.static('dist'))

webserver.listen(PORT, ADDR, function () {
    console.log(`Server is listening on ${ADDR}:${PORT}`);
}).on('error', function (err) {
    console.log(`Unable to listen on ${ADDR}:${PORT} : ${err.code}`);
});

