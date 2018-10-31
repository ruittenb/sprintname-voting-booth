'use strict';

const { Auth0Lock } = require('auth0-lock');

/** **********************************************************************
 * Authentication
 */

module.exports = function ()
{
    /** **********************************************************************
     * Static data
     */
    const idTokenKey     = 'elmVotingApp.idToken';
    const accessTokenKey = 'elmVotingApp.accessToken';
    const profileKey     = 'elmVotingApp.profile';

    /** **********************************************************************
     * Constructor
     */
    let Authentication = function ()
    { }

    /** **********************************************************************
     * Register ourselves with the elmClient
     */
    Authentication.prototype.register = function (elmClient)
    {
        this.elmClient = elmClient;

        // ----- messages incoming from elm -----

        // user clicked 'login'
        elmClient.ports.auth0ShowLock.subscribe((lockParameters) => {
            var [ clientId, clientDomain, options ] = lockParameters;
            this.lock = new Auth0Lock(clientId, clientDomain, options);
            this.lock.show();
            this.lock.on('authenticated', this.onLockAuthenticated.bind(this));
        });

        // user clicked 'logout'
        elmClient.ports.auth0Logout.subscribe(() => {
            this.deleteCredentials();
        });

    }; // register

    /** **********************************************************************
     * proceed after succesful login attempt
     */
    Authentication.prototype.onLockAuthenticated = function (authResult)
    {
        let idToken     = authResult.idToken;
        let accessToken = authResult.accessToken;

        // It is not always clear whether we need to fetch the profile here,
        // so we do it anyway, just to be sure.
        // Use the accessToken to fetch the profile.
        this.lock.getUserInfo(accessToken, (err, profile) => {

            if (!err) {
                let credentials = { idToken, accessToken, profile };
                this.storeCredentials(credentials);
                this.elmClient.ports.onAuthenticationReceived.send(credentials);
            } else {
                console.error('error fetching profile: ', err);
                let reason = err.details;
                this.deleteCredentials();
                this.elmClient.ports.onAuthenticationFailed.send(reason);
            };
        }); // getUserInfo
    }; // onLockAuthenticated

    /** **********************************************************************
     * destroy authentication information
     */
    Authentication.prototype.deleteCredentials = function ()
    {
        localStorage.removeItem(idTokenKey);
        localStorage.removeItem(accessTokenKey);
        localStorage.removeItem(profileKey);
    };

    /** **********************************************************************
     * store authentication information
     */
    Authentication.prototype.storeCredentials = function ({ idToken, accessToken, profile })
    {
        localStorage.setItem(idTokenKey,     idToken);
        localStorage.setItem(accessTokenKey, accessToken);
        localStorage.setItem(profileKey,     JSON.stringify(profile));
    };

    /** **********************************************************************
     * retrieve authentication information
     */
    Authentication.prototype.retrieveCredentials = function ()
    {
        let result      = null;
        let idToken     = localStorage.getItem(idTokenKey);
        let accessToken = localStorage.getItem(accessTokenKey);
        let profile     = localStorage.getItem(profileKey);
        if (idToken && accessToken && profile) {
            result = { idToken, accessToken, profile: JSON.parse(profile) };
        }
        return result;
    };

    return Authentication;

}();

/* vim: set ts=4 sw=4 et list: */
