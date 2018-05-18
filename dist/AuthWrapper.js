'use strict';

require('auth0-lock');

/** **********************************************************************
 * AuthWrapper
 */

module.exports = function ()
{
    /** **********************************************************************
     * Static data
     */
    const clientId = 'n0dhDfP61nzDIRpMaw8UsoPLiNxcxdM9';
    const clientDomain = 'proforto.eu.auth0.com';

    /** **********************************************************************
     * Constructor
     */
    let AuthWrapper = function ()
    {
    }

    /** **********************************************************************
     * Register ourselves with the elmClient
     */
    AuthWrapper.prototype.register = function (elmClient)
    {
        this.elmClient = elmClient;

        // ----- messages incoming from elm -----

        // user clicked 'login'
        elmClient.ports.auth0ShowLock.subscribe((options) => {
            this.lock = new Auth0Lock(clientId, clientDomain, options);
            this.lock.show();
            this.lock.on('authenticated', this.onLockAuthenticated.bind(this));
        });

        // user clicked 'logout'
        elmClient.ports.auth0Logout.subscribe(() => {
            this.deleteCredentials();
            elmClient.ports.onAuthenticationReceived.send(null);
        });

        // ----- messages outgoing to elm -----

        // communicate logout to elm
        // elmClient.ports.onAuth0Logout.send(null);

    }; // register

    /** **********************************************************************
     * proceed after succesful login attempt
     */
    AuthWrapper.prototype.onLockAuthenticated = function (authResult)
    {
        let accessToken = authResult.accessToken;

        // We'll need to fetch the profile here.
        // Use the token in authResult to fetch the profile
        this.lock.getUserInfo(accessToken, (err, profile) => {
            let idToken = authResult.idToken;
            let credentials;

            if (!err) {
                credentials = { idToken, accessToken, profile };
                this.storeCredentials(credentials);
                this.elmClient.ports.onAuthenticationReceived.send(credentials);
            } else {
        console.log('4- err: ', err);
                // result.err = err.details;
                //
                //      // Ensure that optional fields are on the object
                //      result.err.name = result.err.name ? result.err.name : null;
                //      result.err.code = result.err.code ? result.err.code : null;
                //      result.err.statusCode = result.err.statusCode ? result.err.statusCode : null;
                //  }
                //  me.fire(USER_AUTHENTICATED, result);
                this.deleteCredentials();
                this.elmClient.ports.onAuth0Logout.send({});
            };
        }); // getUserInfo
    }; // onAuthenticated

    /** **********************************************************************
     * destroy authentication information
     */
    AuthWrapper.prototype.deleteCredentials = function ()
    {
        localStorage.removeItem('idToken');
        localStorage.removeItem('accessToken');
        localStorage.removeItem('profile');
    };

    /** **********************************************************************
     * store authentication information
     */
    AuthWrapper.prototype.storeCredentials = function ({ idToken, accessToken, profile })
    {
        localStorage.setItem('idToken', idToken);
        localStorage.setItem('accessToken', accessToken);
        localStorage.setItem('profile', JSON.stringify(profile));
    };

    /** **********************************************************************
     * retrieve authentication information
     */
    AuthWrapper.prototype.retrieveCredentials = function ()
    {
        let idToken     = localStorage.getItem('idToken');
        let accessToken = localStorage.getItem('accessToken');
        let profile     = localStorage.getItem('profile');
        return { idToken, accessToken, profile: JSON.parse(profile) };
    };

    return AuthWrapper;

}();

/* vim: set ts=4 sw=4 et list: */
