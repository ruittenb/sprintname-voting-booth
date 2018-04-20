'use strict';

/** **********************************************************************
 * Authenticator
 */

const Authenticator = function (jQuery)
{

    /** **********************************************************************
     * Constructor
     */
    let Authenticator = function ()
    {
        this.lock = this.getLock();

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
     * instantiate and initialize the lock (login) widget
     */
    Authenticator.prototype.getLock = function ()
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
    Authenticator.prototype.logout = function () {
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
    Authenticator.prototype.onLockAuthenticated = function (authResult)
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
    Authenticator.prototype.firebaseSignin = function (jwtToken)
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

    return Authenticator;

}(jQuery);

/** **********************************************************************
 * make certain objects available for debugging
 */

window.Authenticator = new Authenticator();
