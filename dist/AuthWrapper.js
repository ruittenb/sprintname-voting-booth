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

        // ----- messages incoming from elm -----

        // user clicked 'login'
        elmClient.ports.auth0ShowLock.subscribe(
            this.lock.show.bind(this.lock)
        );

        // user clicked 'logout'
        elmClient.ports.auth0Logout.subscribe(() => {
            this.deleteStoredProfile();
            elmClient.ports.onAuthenticationReceived.send(null);
        });

        // ----- messages outgoing to elm -----

        // when authentication was succesful
        this.lock.on('authenticated', (authResult) => {
            this.storeProfile(authResult);
            elmClient.ports.onAuthenticationReceived.send(authResult);
        });

        // communicate logout to elm
        // elmClient.ports.onAuth0Logout.send(null);

    }; // constructor


    /** **********************************************************************
     * destroy authentication information
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
    AuthWrapper.prototype.storeProfile = function ({ idToken, accessToken, profile })
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
        return { idToken, accessToken, profile };
    };

    return AuthWrapper;

}();

/* vim: set ts=4 sw=4 et list: */
