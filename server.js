/**
 * Server that
 * - takes a JWT token
 * - validates it
 * - verifies that it concerns a valid email address
 * - returns a valid Firebase token
 *
 * Usage:
 * - POST a string of the form:
 *   { "jwtToken": "<jwt data>" }
 *
 * See also:
 * - http://blog.pixelastic.com/2017/10/28/authenticating-to-firebase-from-a-server/
 * - http://blog.pixelastic.com/2017/11/01/firebase-authentication-with-auth0/
 * - https://github.com/auth0/node-jsonwebtoken
 */

'use strict';

const Jwt2FirebaseServer = (function () {

    const PORT = 4202;
    const AUTHORIZED_USERS = /^[^@]+@proforto\.nl$/;
    const DATABASE_URL = 'https://sprintname-voting-booth.firebaseio.com';

    const fs = require('fs');
    const express = require('express');
    const bodyParser = require('body-parser');
    const jwt = require('jsonwebtoken');
    const firebaseAdmin = require('firebase-admin');

    /**
     * Constructor.
     */
    let Jwt2FirebaseServer = function ()
    {
        this.publicKey = fs.readFileSync('./dist/public-auth0.key');
        this.serviceAccountKey = require('./dist/serviceAccountKey.json');
        this.startServer();
    };

    /**
     * Start the server.
     */
    Jwt2FirebaseServer.prototype.startServer = function ()
    {
        this.server = express();
        let me = this;

        /**
         * Parses the body test as JSON and exposes the resulting object on request.body
         */
        this.server.use(bodyParser.json());
        this.server.use(function (err, request, response, callback) {
            response.status(err.status).json({ ...err, success : false });
            callback();
        });

        this.server.post('/', async function (request, response) {
            /**
             * Try to retrieve JWT token
             */
            let status, userData, firebaseToken;
            let jwtToken = request.body.jwtToken;
            if (!jwtToken) {
                status = 400;
                return response.status(status).json({
                    success: false,
                    status,
                    message: 'Missing or empty property "jwtToken"'
                });
            };
            /**
             * Try to validate JWT token
             */
            try {
                userData = me.validateJwtToken(jwtToken);
            }
            catch (e) {
                status = e.status || 400;
                return response.status(status).json({
                    success: false,
                    status,
                    message: e.message
                });
            }
            /**
             * Try to issue firebase token
             */
            try {
                firebaseToken = await me.issueFirebaseToken(userData);
            }
            catch (e) {
                status = e.status || 500;
                return response.status(status).json({
                    success: false,
                    status,
                    message: e.message
                });
            }
            response.json({
                success : true,
                firebaseToken
            });
        });

        this.server.listen(PORT, function (err) {
            if (err) {
                return console.log('Unable to listen on port', PORT, ': ', err);
            }
            console.log('Server is listening on port', PORT);
        });
    };

    /**
     * Validate the JWT token.
     * Also validate that this is an authorized account.
     * Throw an error if invalid or unauthorized.
     *
     * @return userData from JWT token if successful.
     */
    Jwt2FirebaseServer.prototype.validateJwtToken = function (jwtToken) {
        let userData;
        try {
            userData = jwt.verify(jwtToken, this.publicKey);
            if (!userData) {
                throw new Error('Not allowed: JWT token could not be validated');
            }
            if (!userData.email_verified) {
                throw new Error('Not allowed: this email address has not been verified');
            }
            if (!userData.email.match(AUTHORIZED_USERS)) {
                throw new Error('Not allowed: this email address is not authorized');
            }
        }
        catch (e) {
            throw({ status: 403, message: e.message });
        }
        return userData;
    };

    /**
     * use the service account key to authenticate with the firebase server
     */
    Jwt2FirebaseServer.prototype.issueFirebaseToken = async function (userData) {

        let firebaseToken;
        firebaseAdmin.initializeApp({
            credential: firebaseAdmin.credential.cert(this.serviceAccountKey),
            databaseURL: DATABASE_URL
        });

        firebaseToken = await firebaseAdmin.auth().createCustomToken(userData.email);
        return firebaseToken;
    };

    return Jwt2FirebaseServer;
})();

const server = new Jwt2FirebaseServer();


//    "gmailUsers": {
//      "$uid": {
//        ".write": "auth.profile.email_verified == true && auth.profile.email.matches(/.*@proforto.nl$/)"
//      }
//    }

