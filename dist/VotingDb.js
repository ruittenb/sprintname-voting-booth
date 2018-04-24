'use strict';

/** **********************************************************************
 * VotingDb
 */

const VotingDb = (function (jQuery, firebase)
{
    /** **********************************************************************
     * Static data for the event hub
     */
    const fires = [
        FIREBASE_SIGNIN_FAILED,
        TEAM_RATINGS_LOADED,
        USER_RATINGS_LOADED
    ];

    const tokenserverUrl = `http://${window.location.hostname}:4202/`;

    /** **********************************************************************
     * Constructor
     */
    let VotingDb = function (eventHub)
    {
        this.init();

        eventHub.register(this, fires);

        // user logged out
        eventHub.on(USER_REQUESTED_LOGOUT, this.logout.bind(this));
        eventHub.on(ID_TOKEN_RECEIVED_FROM_AUTH, this.login.bind(this));
        eventHub.on(ID_TOKEN_FOUND_IN_STORAGE, this.login.bind(this));
        eventHub.on(USER_VOTES_CAST, this.castVote.bind(this));

        let me = this;

        // when pokedex loads
        this.votingDb.pokedex.on('value', function (data) {
            let pokedex = data.val();
            me.fire(POKEDEX_LOADED, pokedex);
        });

        // when user ratings load
        this.votingDb.users.once('value', function (data) {
            let team = data.val();
            me.fire(TEAM_RATINGS_LOADED, team);
        });
        this.votingDb.users.on('child_changed', function (data) {
            let user = data.val();
            me.fire(USER_RATINGS_LOADED, user);
        });

    }; // constructor

    /** **********************************************************************
     * inherit Observable, but restore the constructor
     */
    VotingDb.prototype = new Observable();
    VotingDb.prototype.constructor = VotingDb;

    /** **********************************************************************
     * instantiate and initialize the database
     */
    VotingDb.prototype.init = function ()
    {
        const firebaseConfig = {
            apiKey            : "AIzaSyAm4--Q2MjVWGZYW-IC8LPZARXJq-XyHXA",
            databaseURL       : "https://sprintname-voting-booth.firebaseio.com",
            authDomain        : "sprintname-voting-booth.firebaseapp.com",
            storageBucket     : "sprintname-voting-booth.appspot.com",
            messagingSenderId : "90828432994"
        };

        firebase.initializeApp(firebaseConfig);

        this.votingDb = {
            database: firebase.database(),
            pokedex : firebase.database().ref('pokedex'),
            users   : firebase.database().ref('users')
        };
    };

    /** **********************************************************************
     * take a JWT token, obtain a firebase token, and log in in firebase
     */
    VotingDb.prototype.login = function (jwtToken)
    {
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
                // if the token was expired, try to obtain a new one
                let retry = status === 403;
                me.fire(FIREBASE_SIGNIN_FAILED, retry);
            });
        return;
    };

    /** **********************************************************************
     * Log out of firebase
     */
    VotingDb.prototype.logout = function ()
    {
        firebase.auth().signOut();
    };

    /** **********************************************************************
     * database action: casting votes
     */
    VotingDb.prototype.castVote = function (userRatings)
    {
        // id === null would correspond to a delete request.
        // id should not be null, but let's be defensive here.
        if (userRatings.id !== null) {
            let userRef = this.votingDb.users.child(userRatings.id);
            userRef.set(userRatings);
        }
    };

    return VotingDb;

})(jQuery, firebase);

