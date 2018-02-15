'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('./index.html'); // ensure index.html gets copied during build

// instantiate the main voting app
let Elm = require('./Main.elm');
let votingApp = (function () {
    const storedProfile = localStorage.getItem('profile');
    const storedToken = localStorage.getItem('token');
    const authData = storedProfile && storedToken ? { profile: JSON.parse(storedProfile), token: storedToken } : null;
    return Elm.Main.fullscreen(authData);
})();

// instantiate the lock (login) widget
let lock = (function () {
    const clientId = 'n0dhDfP61nzDIRpMaw8UsoPLiNxcxdM9';
    const clientDomain = 'proforto.eu.auth0.com';
    const options = {
        allowedConnections: ['google-oauth2'], // 'Username-Password-Authentication'
        autoclose: true,
        audience: 'proforto.eu.auth0.com/userinfo',
        auth: {
            redirect: false,
            responseType: 'token',
            params: {
                // Learn about scopes: https://auth0.com/docs/scopes
                scope: 'openid email profile'
            }
        }
    };
    return new Auth0Lock(clientId, clientDomain, options);
})();

// preload images as requested by elm
votingApp.ports.preloadImages.subscribe(function (list) {
    window.preloader = new Preloader(list);
});

// show lock (login) widget if the elm app requests it
votingApp.ports.auth0showLock.subscribe(function (opts) {
    lock.show(opts);
});

// logout if the elm app requests it
votingApp.ports.auth0logout.subscribe(function (opts) {
    localStorage.removeItem('profile');
    localStorage.removeItem('token');
});

// on succesful authentication, pass the credentials to elm
lock.on("authenticated", function (authResult) {
    // Use the token in authResult to getProfile() and save it to localStorage
    lock.getUserInfo(authResult.accessToken, function (err, profile) {
        let result = { err: null, ok: null };
        let token = authResult.accessToken;

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

