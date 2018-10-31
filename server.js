
'use strict';

const FirebaseTokenServer = require('./tokenserver/tokenserver.js');

const PORT        = 4201;
const express     = require('express');
const webserver   = express();
const tokenserver = new FirebaseTokenServer(webserver);

webserver.use(express.static('dist'))

webserver.listen(PORT, function (err) {
    if (err) {
        return console.log('Unable to listen on port', PORT, ': ', err);
    }
    console.log('Server is listening on port', PORT);
});

