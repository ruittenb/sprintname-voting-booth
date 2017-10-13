'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');

require('./index.html'); // ensure index.html gets copied during build

let Elm = require('./Main.elm');

const clientId = 'n0dhDfP61nzDIRpMaw8UsoPLiNxcxdM9';
const clientDomain = 'proforto.eu.auth0.com';
const options = {
    allowedConnections: ['google-oauth2'], // 'Username-Password-Authentication'
    auth: {
        redirect: false,
        responseType: 'id_token',
        params: {
            // Learn about scopes: https://auth0.com/docs/scopes
            scope: 'openid email profile'
        }
    }
};
let lock = new Auth0Lock(clientId, clientDomain, options);
let storedProfile = localStorage.getItem('profile');
let storedToken = localStorage.getItem('token');
let authData = storedProfile && storedToken ? { profile: JSON.parse(storedProfile), token: storedToken } : null;
let votingApp = Elm.Main.fullscreen(authData);

// Listen to image preload requests
votingApp.ports.preloadImages.subscribe(preloadImages);

// Show Auth0 lock subscription
votingApp.ports.auth0showLock.subscribe(function (opts) {
    lock.show();
});

// Log out of Auth0 subscription
votingApp.ports.auth0logout.subscribe(function (opts) {
    localStorage.removeItem('profile');
    localStorage.removeItem('token');
});

// Listening for the authenticated event
lock.on("authenticated", function (authResult) {

    // Use the token in authResult to getProfile() and save it to localStorage
    lock.getProfile(authResult.idToken, function (err, profile) {
        let result = { err: null, ok: null };
        let token = authResult.idToken;

        if (!err) {
            result.ok = { profile: profile, token: token };
            localStorage.setItem('profile', JSON.stringify(profile));
            localStorage.setItem('token', token);
        } else {
            result.err = err.details;

            // Ensure that optional fields are on the object
            result.err.name = result.err.name ? result.err.name : null;
            result.err.code = result.err.code ? result.err.code : null;
            result.err.statusCode = result.err.statusCode ? result.err.statusCode : null;
        }
        votingApp.ports.auth0authResult.send(result);
    });
});

