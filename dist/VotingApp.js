'use strict';

require('./Globals.js');
const Preloader  = require('./Preloader.js');
const Observable = require('./Observable.js');
const Elm        = require('../src/Main.elm');

/** **********************************************************************
 * VotingApp
 */

module.exports = (function (jQuery)
{
    /** **********************************************************************
     * Static data for the event hub
     */
    const fires = [
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
        this.preloader = new Preloader('#' + preloaderControlNodeId);

        eventHub.register(this, fires);

    }; // constructor

    /** **********************************************************************
     * inherit Observable, but restore the constructor
     */
    VotingApp.prototype = new Observable();
    VotingApp.prototype.constructor = VotingApp;

    /** **********************************************************************
     * GO!
     */
    VotingApp.prototype.run = function (idToken, accessToken, profile)
    {
        const storedProfile = {
            idToken: idToken,
            accessToken: accessToken,
            profile: profile,
        };
        const appNode = document.getElementById(votingAppNodeId);
        this.elmClient = Elm.Main.embed(appNode, JSON.stringify(storedProfile));

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
        this.elmClient.ports.auth0ShowLock.subscribe(function () {
            me.fire(USER_REQUESTED_LOGIN_DIALOG);
        });
        // logout if the elm app requests it
        this.elmClient.ports.auth0Logout.subscribe(function () {
            me.fire(USER_REQUESTED_LOGOUT);
        });
        // save user ratings to firebase
        this.elmClient.ports.saveUserRatings.subscribe(function (userRatings) {
            me.fire(USER_VOTES_CAST, userRatings);
        });

        // preload images as requested by elm
        this.elmClient.ports.preloadImages.subscribe(function (imageList) {
            me.preloader.queue(imageList);
        });
    };

    /** **********************************************************************
     * when credentials change
     */
    VotingApp.prototype.sendAuthResult = function (idToken, accessToken, profile)
    {
        const result = {
            idToken: idToken,
            accessToken: accessToken,
            profile: profile,
        };
        this.elmClient.ports.onAuth0Result.send(JSON.stringify(result));
    };

    /** **********************************************************************
     * destroy identity
     */
    VotingApp.prototype.appLogout = function ()
    {
        // communicate logout to elm
        this.elmClient.ports.onAuth0Logout.send(null);
    };

    return VotingApp;

})(jQuery);

/* vim: set ts=4 sw=4 et list: */
