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
    let AuthWrapper = function (elmClient)
    {
        this.lock = new Auth0Lock(clientId, clientDomain, {});

    }

    /** **********************************************************************
     * Register ourselves with the elmClient
     */
    AuthWrapper.prototype.register = function (elmClient)
    {
        // ----- messages incoming from elm -----

        // user clicked 'login'
        elmClient.ports.auth0ShowLock.subscribe(
            this.lock.show.bind(this.lock)
        );

        // user clicked 'logout'
        elmClient.ports.auth0Logout.subscribe(() => {
            this.deleteCredentials();
            elmClient.ports.onAuthenticationReceived.send(null);
        });

        // ----- messages outgoing to elm -----

        // when authentication was succesful
        this.lock.on('authenticated', (credentials) => {

            // we'll need to fetch the profile here.
            console.log(credentials);
            this.storeCredentials(credentials);
            elmClient.ports.onAuthenticationReceived.send(credentials.profile);
        });

        // communicate logout to elm
        // elmClient.ports.onAuth0Logout.send(null);

    }; // constructor


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
        return { idToken, accessToken, profile };
    };

    return AuthWrapper;

}();

/* vim: set ts=4 sw=4 et list: */
