'use strict';

require('Preloader.js');

/** **********************************************************************
 * VotingApp
 */

const VotingApp = (function (jQuery)
{
    /** **********************************************************************
     * Static data for the event hub
     */
    const fires = [
        APP_REQUESTS_STORED_PROFILE,
        USER_REQUESTED_LOGIN_DIALOG,
        USER_REQUESTED_LOGOUT,
        USER_VOTES_CAST
    ];

    const preloaderControlNodeId = 'version';
    const votingAppNodeId = 'voting-app-node';

    /** **********************************************************************
     * Constructor
     */
    let VotingApp = function (eventHub)
    {
        this.eventHub = eventHub;

        eventHub.register(this, fires);
        eventHub.on(PROFILE_PROBED_IN_STORAGE, this.receiveProfile.bind(this));

    }; // constructor

    /** **********************************************************************
     * inherit Observable, but restore the constructor
     */
    VotingApp.prototype = new Observable();
    VotingApp.prototype.constructor = VotingApp;

    /** **********************************************************************
     * signal GO!
     */
    VotingApp.prototype.start = function (result) {
        this.fire(APP_REQUESTS_STORED_PROFILE);
    };

    /** **********************************************************************
     * when credentials change
     */
    VotingApp.prototype.sendAuthResult = function (result) {
        this.elmClient.ports.onAuth0Result.send(result);
    };

    /** **********************************************************************
     * destroy identity
     */
    AuthWrapper.prototype.appLogout = function ()
    {
        // communicate logout to elm
        this.elmClient.ports.onAuth0Logout.send(null);
    };

    /** **********************************************************************
     * start the elm app with credentials, if possible
     */
    VotingApp.prototype.receiveProfile = function (profile, accessToken)
    {
        this.preloader = new Preloader('#' + preloaderControlNodeId);

        const elm = require('./Main.elm');
        const appNode = document.getElementById(votingAppNodeId);
        const authData = profile && accessToken
            ? { profile: JSON.parse(profile), token: accessToken } : null;
        this.elmClient = elm.Main.embed(appNode, authData);

        let me = this;

        this.eventHub.on(USER_AUTHENTICATED, this.sendAuthResult.bind(this));
        this.eventHub.on(FIREBASE_SIGNIN_FAILED, this.appLogout.bind(this));

        // database actions: loading ratings and pokedex
        this.eventHub.on(POKEDEX_LOADED, function (pokedex) {
            me.elmClient.ports.onLoadPokedex.send(pokedex);
        });
        this.eventHub.on(TEAM_RATINGS_LOADED, function (team) {
            me.elmClient.ports.onLoadTeamRatings.send(team);
        });
        this.eventHub.on(USER_RATINGS_LOADED, function (user) {
            me.elmClient.ports.onLoadUserRatings.send(user);
        });

        // user clicked 'login'
        this.elmClient.ports.auth0showLock.subscribe(function () {
            me.fire(USER_REQUESTED_LOGIN_DIALOG);
        });
        // logout if the elm app requests it
        this.elmClient.ports.auth0logout.subscribe(function () {
            me.fire(USER_REQUESTED_LOGOUT);
        });
        // save user ratings to firebase
        this.elmClient.ports.saveUserRatings.subscribe(function (userRatings) {
            me.fire(USER_VOTES_CAST, userRatings);
        });

        // preload images as requested by elm
        this.elmClient.ports.preloadImages.subscribe(function (imageList) {
            if (elm_initiates_preload) {
                me.preloader.queue(imageList);
            }
        });
    }; // start

    return VotingApp;

})(jQuery);

