'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('./index.html'); // ensure index.html gets copied during build

/** **********************************************************************
 * main
 */

const ElmConnector = function (jQuery, firebase)
{
    const elm_initiates_preload = true;

    /** **********************************************************************
     * Constructor
     */
    let ElmConnector = function ()
    {
        // instantiate main objects
        this.votingApp = this.getVotingApp();
        this.votingDb = this.getVotingDb(firebase);
        this.lock = this.getLock();
        this.preloader = new Preloader('#version');

        // communication between lock and elm
        let me = this;

        // show lock (login) widget if the elm app requests it
        this.votingApp.ports.auth0showLock.subscribe(this.lock.show.bind(this.lock));

        // when authentication was succesful
        this.lock.on('authenticated', this.onLockAuthenticated.bind(this));

        // logout if the elm app requests it
        this.votingApp.ports.auth0logout.subscribe(this.logout.bind(this));

        /** **********************************************************************
         * database actions: loading and saving ratings
         */

        // load user ratings and send them to elm
        this.votingDb.users.once('value', function (data) {
            let team = data.val();
            me.votingApp.ports.onLoadTeamRatings.send(team);
        });
        this.votingDb.users.on('child_changed', function (data) {
            let user = data.val();
            me.votingApp.ports.onLoadUserRatings.send(user);
        });

        // save user ratings to firebase
        this.votingApp.ports.saveUserRatings.subscribe(function (userRatings) {
            // id === null would correspond to a delete request.
            // id should not be null, but let's be defensive here.
            if (userRatings.id !== null) {
                let userRef = me.votingDb.users.child(userRatings.id);
                userRef.set(userRatings);
            }
        });

        /** **********************************************************************
         * database actions: loading pokedex and preloading images
         */

        // load pokedex and send it to elm
        this.votingDb.pokedex.on('value', function (data) {

            let pokedex = data.val();
            me.votingApp.ports.onLoadPokedex.send(pokedex);
            if (!elm_initiates_preload) {
                let variantImages = pokedex.map(function (p) {
                    return p.variants.map(function (v) {
                        return {
                            generation : p.generation,
                            imageUrl   : v.image
                        };
                    });
                }).reduce((n, m) => n.concat(m), []);
                me.preloader.queue(variantImages);
            }
        });

        // preload images as requested by elm
        this.votingApp.ports.preloadImages.subscribe(function (imageList) {
            if (elm_initiates_preload) {
                me.preloader.queue(imageList);
            }
        });
    }; // constructor

    /** **********************************************************************
     * instantiate and initialize main voting app
     */
    ElmConnector.prototype.getVotingApp = function ()
    {
        let storedProfile     = localStorage.getItem('profile');
        let storedAccessToken = localStorage.getItem('accessToken');
        let storedIdToken     = localStorage.getItem('idToken');
        if (storedProfile && storedIdToken) {
            this.firebaseSignin(storedIdToken);
        }
        const Elm = require('./Main.elm');
        const appNode = document.getElementById('voting-app-node');
        const authData = storedProfile && storedAccessToken
            ? { profile: JSON.parse(storedProfile), token: storedAccessToken } : null;
        return Elm.Main.embed(appNode, authData);
    };

    /** **********************************************************************
     * instantiate and initialize the firebase client object
     */

    ElmConnector.prototype.getVotingDb = function (firebase)
    {
        const firebaseConfig = {
            apiKey            : "AIzaSyAm4--Q2MjVWGZYW-IC8LPZARXJq-XyHXA",
            databaseURL       : "https://sprintname-voting-booth.firebaseio.com",
            authDomain        : "sprintname-voting-booth.firebaseapp.com",
            storageBucket     : "sprintname-voting-booth.appspot.com",
            messagingSenderId : "90828432994"
        };

        firebase.initializeApp(firebaseConfig);

        return {
            database: firebase.database(),
            pokedex : firebase.database().ref('pokedex'),
            users   : firebase.database().ref('users')
        };
    };


    /** **********************************************************************
     * instantiate and initialize the lock (login) widget
     */
    ElmConnector.prototype.getLock = function ()
    {
        const clientId = 'n0dhDfP61nzDIRpMaw8UsoPLiNxcxdM9';
        const clientDomain = 'proforto.eu.auth0.com';
        const options = {
            allowedConnections: ['google-oauth2'], // or 'Username-Password-Authentication'
            autoclose: true,
            audience: 'proforto.eu.auth0.com/userinfo',
            // learn more about authentication parameters at:
            // https://auth0.com/docs/libraries/lock/v11/sending-authentication-parameters
            auth: {
                redirect: false,
                responseType: 'token id_token',
                params: {
                    // Learn more about scopes at: https://auth0.com/docs/scopes
                    scope: 'openid email profile'
                }
            }
        };
        return new Auth0Lock(clientId, clientDomain, options);
    };

    /**
     * Destroy Auth0 token
     */
    ElmConnector.prototype.logout = function () {
        localStorage.removeItem('profile');
        localStorage.removeItem('accessToken');
        localStorage.removeItem('idToken');
        firebase.auth().signOut();
    };

    /**
     * on succesful authentication, pass the credentials to elm
     *
     * maybe replace this with http://package.elm-lang.org/packages/kkpoon/elm-auth0/2.0.0/Auth0
     */
    ElmConnector.prototype.onLockAuthenticated = function (authResult)
    {
        let me = this;

        // Use the token in authResult to getUserInfo() and save it to localStorage
        this.lock.getUserInfo(authResult.accessToken, function (err, profile) {
            let result = { err: null, ok: null };
            let accessToken = authResult.accessToken;
            let idToken = authResult.idToken;

            if (!err) {
                result.ok = { profile: profile, token: accessToken };
                localStorage.setItem('profile', JSON.stringify(profile));
                localStorage.setItem('accessToken', accessToken);
                localStorage.setItem('idToken', idToken);
                me.firebaseSignin(idToken); // TODO perhaps move this to caller
            } else {
                result.err = err.details;

                // Ensure that optional fields are on the object
                result.err.name = result.err.name ? result.err.name : null;
                result.err.code = result.err.code ? result.err.code : null;
                result.err.statusCode = result.err.statusCode ? result.err.statusCode : null;
            }
            me.votingApp.ports.onAuth0Result.send(result);
        });
    };

    /** **********************************************************************
     * take a JWT token, obtain a firebase token, and log in in firebase
     */
    ElmConnector.prototype.firebaseSignin = function (jwtToken)
    {
        const tokenserverUrl = `http://${window.location.hostname}:4202/`;
        let me = this;

        jQuery
            .post({
                url: tokenserverUrl,
                data: { jwtToken }
            })
            .then(function (tokenData) {
                if (tokenData.success) {
                    return Promise.resolve(tokenData.firebaseToken);
                } else {
                    return Promise.reject(tokenData);
                }
            })
            .then(function (firebaseToken) {
                jQuery('#message-box').text('').removeClass('error warning');
                return firebase.auth().signInWithCustomToken(firebaseToken);
            })
            .catch(function (e) {
                console.error('caught: ', e);
                let status = e.status || 500;
                let message = e.responseJSON ? e.responseJSON.message : (e.message || "Server error");
                jQuery('#message-box').text(status + ': ' + message).addClass('error');
                // communicate logout to elm
                me.votingApp.ports.onAuth0Logout.send(null);
                // destroy tokens
                me.logout();
                // if the token was expired, try to obtain a new one
                if (status === 403) {
                    me.lock.show.call(me.lock);
                }
            });
        return;
    };

    return ElmConnector;

}(jQuery, firebase);

/*
lock.checkSession({}, function (error, authResult) {
  if (error || !authResult) {
    lock.show();
  } else {
    // user has an active session, so we can use the accessToken directly.
    lock.getUserInfo(authResult.accessToken, function (error, profile) {
      console.log(error, profile);
    });
  }
});
*/

/*
 firebase.auth().onAuthStateChanged(function(user) {
  if (user) {
    // User is signed in.
    var isAnonymous = user.isAnonymous;
    var uid = user.uid;
    // ...
  } else {
    // User is signed out.
    // ...
  }
  // ...
});
*/

/** **********************************************************************
 * make certain objects available for debugging
 */

window.elmConnector = new ElmConnector();
