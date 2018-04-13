'use strict';

const TOKENSERVER_URL = `http://${window.location.hostname}:4202/`;

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('./index.html'); // ensure index.html gets copied during build

/** **********************************************************************
 * prepare function for firebase login
 */

const firebaseSignin = function (jwtToken)
{
    jQuery
        .post({
            url: TOKENSERVER_URL,
            data: { jwtToken }
        })
        .then(function (tokenData) {
            if (tokenData.success) {
                return Promise.resolve(tokenData.firebaseToken);
            } else {
                return Promise.reject(tokenData);
            }
        })
        .then( function (firebaseToken) {
            return firebase.auth().signInWithCustomToken(firebaseToken);
        })
        .catch(function (e) {
            console.log('catch ', e, arguments);
            let status = e.status || 500;
            jQuery('#message-box').text(status + ': ' + e.message).addClass('error');
        });
    return;
};

/** **********************************************************************
 * instantiate main objects
 */

// instantiate the main voting app
let Elm = require('./Main.elm');
let votingApp = (function () {
    let storedProfile, storedAccessToken, storedIdToken;    
    // const storedProfile     = localStorage.getItem('profile');
    // const storedAccessToken = localStorage.getItem('accessToken');
    // const storedIdToken     = localStorage.getItem('idToken');
    if (storedProfile && storedIdToken) {
        firebaseSignin(storedIdToken);
    }
    const authData = storedProfile && storedAccessToken
        ? { profile: JSON.parse(storedProfile), token: storedAccessToken } : null;
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
        // learn more about authentication parameters:
        // https://auth0.com/docs/libraries/lock/v11/sending-authentication-parameters
        auth: {
            redirect: false,
            responseType: 'token id_token',
            params: {
                // Learn about scopes: https://auth0.com/docs/scopes
                scope: 'openid email profile'
            }
        }
    };
    return new Auth0Lock(clientId, clientDomain, options);
})();

/** **********************************************************************
 * communication between lock and elm
 */

// show lock (login) widget if the elm app requests it
votingApp.ports.auth0showLock.subscribe(function (opts) {
    lock.show(opts);
});

// logout if the elm app requests it
votingApp.ports.auth0logout.subscribe(function (opts) {
    localStorage.removeItem('profile');
    localStorage.removeItem('accessToken');
    localStorage.removeItem('idToken');
});

// on succesful authentication, pass the credentials to elm
lock.on("authenticated", function (authResult) {
    // Use the token in authResult to getProfile() and save it to localStorage
    lock.getUserInfo(authResult.accessToken, function (err, profile) {
        let result = { err: null, ok: null };
        let accessToken = authResult.accessToken;
        let idToken = authResult.idToken;

        if (!err) {
            result.ok = { profile: profile, token: accessToken };
            localStorage.setItem('profile', JSON.stringify(profile));
            localStorage.setItem('accessToken', accessToken);
            localStorage.setItem('idToken', idToken);
            firebaseSignin(idToken);
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

/** **********************************************************************
 * database actions: loading and saving ratings
 */

// load user ratings and send them to elm
votingDb.users.once('value', function (data) {
    let team = data.val();
    votingApp.ports.onLoadTeamRatings.send(team);
});

votingDb.users.on('child_changed', function (data) {
    let user = data.val();
    votingApp.ports.onLoadUserRatings.send(user);
});

votingApp.ports.saveUserRatings.subscribe(function (userRatings) {
    if (userRatings.id) {
        let userRef = votingDb.users.child(userRatings.id); //.child('ratings');
        userRef.set(userRatings); //.ratings);
    }
});

/** **********************************************************************
 * database actions: loading pokedex and preloading images
 */

const elm_initiates_preload = true;

let preloader = new Preloader('#version');

// load pokedex and send it to elm
votingDb.pokedex.on('value', function (data) {
    let pokedex = data.val();
    votingApp.ports.onLoadPokedex.send(pokedex);
    if (!elm_initiates_preload) {
        let variantImages = pokedex.map(function (p) {
            return p.variants.map(function (v) {
                return {
                    generation : p.generation,
                    imageUrl   : v.image
                };
            });
        }).reduce((n, m) => n.concat(m), []);
        preloader.queue(variantImages);
    }
});

// preload images as requested by elm
votingApp.ports.preloadImages.subscribe(function (imageList) {
    if (elm_initiates_preload) {
        preloader.queue(imageList);
    }
});


/** **********************************************************************
 * make certain objects available for debugging
 */

window.preloader = preloader;
window.votingDb  = votingDb;

