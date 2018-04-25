'use strict';

require('auth0-lock');
require('./Globals.js');
const Observable = require('./Observable.js');

/** **********************************************************************
 * AuthWrapper
 */

module.exports = function (jQuery)
{
    /** **********************************************************************
     * Static data for the event hub
     */
    const fires = [
        ID_TOKEN_RECEIVED_FROM_AUTH,
        ID_TOKEN_FOUND_IN_STORAGE,
        PROFILE_PROBED_IN_STORAGE,
        USER_AUTHENTICATED
    ];

    /** **********************************************************************
     * Constructor
     */
    let AuthWrapper = function (eventHub)
    {
        this.init();

        eventHub.register(this, fires);

        eventHub.on(APP_REQUESTS_STORED_PROFILE, this.probeStoredProfile.bind(this));
        eventHub.on(USER_REQUESTED_LOGIN_DIALOG, this.show.bind(this));
        eventHub.on(USER_REQUESTED_LOGOUT, this.logout.bind(this));
        eventHub.on(FIREBASE_SIGNIN_FAILED, this.forceLogout.bind(this));

        // when authentication was succesful
        this.lock.on('authenticated', this.onLockAuthenticated.bind(this));
    }; // constructor

    /** **********************************************************************
     * inherit Observable, but restore the constructor
     */
    AuthWrapper.prototype = new Observable();
    AuthWrapper.prototype.constructor = AuthWrapper;

    /** **********************************************************************
     * instantiate and initialize the lock (login) widget
     */
    AuthWrapper.prototype.init = function ()
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
        this.lock = new Auth0Lock(clientId, clientDomain, options);
    };

    /** **********************************************************************
     * start: try to find a stored id token
     */
    AuthWrapper.prototype.probeStoredProfile = function ()
    {
        let storedProfile     = localStorage.getItem('profile');
        let storedAccessToken = localStorage.getItem('accessToken');
        let storedIdToken     = localStorage.getItem('idToken');
        if (storedProfile && storedIdToken) {
            // for firebase
            this.fire(ID_TOKEN_FOUND_IN_STORAGE, storedIdToken);
        }
        this.fire(PROFILE_PROBED_IN_STORAGE, storedProfile, storedAccessToken);
    };


    /** **********************************************************************
     * show the login dialog
     */
    AuthWrapper.prototype.show = function ()
    {
        this.lock.show();
    };

    /** **********************************************************************
     * on succesful authentication, pass the credentials to elm
     *
     * maybe replace this with http://package.elm-lang.org/packages/kkpoon/elm-auth0/2.0.0/Auth0
     */
    AuthWrapper.prototype.onLockAuthenticated = function (authResult)
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
                me.fire(ID_TOKEN_RECEIVED_FROM_AUTH, idToken);
            } else {
                result.err = err.details;

                // Ensure that optional fields are on the object
                result.err.name = result.err.name ? result.err.name : null;
                result.err.code = result.err.code ? result.err.code : null;
                result.err.statusCode = result.err.statusCode ? result.err.statusCode : null;
            }
            me.fire('USER_AUTHENTICATED', result);
        });
    };

    /** **********************************************************************
     * Logging out essentially means destroying the token
     */
    AuthWrapper.prototype.logout = function ()
    {
        localStorage.removeItem('profile');
        localStorage.removeItem('accessToken');
        localStorage.removeItem('idToken');
    };

    /** **********************************************************************
     * External forces require logging out
     */
    AuthWrapper.prototype.forceLogout = function (retry)
    {
        this.votingApp.ports.onAuth0Logout.send(null);
        // destroy tokens
        this.logout();
        if (retry) {
            this.show();
        }
    };

    return AuthWrapper;

}(jQuery);

/* vim: set ts=4 sw=4 et list: */
