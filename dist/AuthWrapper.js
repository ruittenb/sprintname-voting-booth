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
        USER_AUTHENTICATED
    ];

    /** **********************************************************************
     * Constructor
     */
    let AuthWrapper = function (eventHub)
    {
        eventHub.register(this, fires);

        eventHub.on(USER_REQUESTED_LOGIN_DIALOG, this.show.bind(this));
        eventHub.on(USER_REQUESTED_LOGOUT, this.deleteStoredProfile.bind(this));
        eventHub.on(FIREBASE_SIGNIN_FAILED, this.forceLogout.bind(this));

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

        this.lock = new Auth0Lock(clientId, clientDomain, {});

        // when authentication was succesful
        this.lock.on('authenticated', this.onLockAuthenticated.bind(this));
    };

    /** **********************************************************************
     * show the login dialog
     */
    AuthWrapper.prototype.show = function ()
    {
        if (!this.lock) {
            this.init();
        }
        this.lock.show();
    };

    /** **********************************************************************
     * on succesful authentication, pass the credentials to elm
     *
     * maybe replace this with http://package.elm-lang.org/packages/kkpoon/elm-auth0/2.0.0/Auth0
     */
    AuthWrapper.prototype.onLockAuthenticated = function (authResult)
    {
        let profile = authResult.profile;
        let accessToken = authResult.accessToken;
        let idToken = authResult.idToken;
        this.storeProfile(idToken, accessToken, profile);

        this.fire(ID_TOKEN_RECEIVED_FROM_AUTH, idToken);
        this.fire(USER_AUTHENTICATED, accessToken, profile);
    };

    /** **********************************************************************
     * Logging out essentially means destroying the token
     */
    AuthWrapper.prototype.deleteStoredProfile = function ()
    {
        localStorage.removeItem('idToken');
        localStorage.removeItem('accessToken');
        localStorage.removeItem('profile');
    };

    /** **********************************************************************
     * store authentication information
     */
    AuthWrapper.prototype.storeProfile = function (idToken, accessToken, profile)
    {
        localStorage.setItem('idToken', idToken);
        localStorage.setItem('accessToken', accessToken);
        localStorage.setItem('profile', JSON.stringify(profile));
    };

    /** **********************************************************************
     * retrieve authentication information
     */
    AuthWrapper.prototype.retrieveProfile = function ()
    {
        let idToken     = localStorage.getItem('idToken');
        let accessToken = localStorage.getItem('accessToken');
        let profile     = localStorage.getItem('profile');
        return [ idToken, accessToken, profile ];
    };

    /** **********************************************************************
     * External forces require logging out
     */
    AuthWrapper.prototype.forceLogout = function (retry)
    {
        // destroy tokens
        this.deleteStoredProfile();
        if (retry) {
            this.show();
        }
    };

    return AuthWrapper;

}(jQuery);

/* vim: set ts=4 sw=4 et list: */
