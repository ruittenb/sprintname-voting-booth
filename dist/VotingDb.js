'use strict';

const firebase = require('firebase');
require('firebase/auth');
require('firebase/database');

/** **********************************************************************
 * VotingDb
 */

module.exports = (function (jQuery, firebase)
{
    /** **********************************************************************
     * Static data
     */
    const tokenserverUrl = `http://${window.location.hostname}:4202/`;

    /** **********************************************************************
     * Constructor
     */
    let VotingDb = function (elmClient)
    {
        this.init();

        return;

        // ----- messages incoming from elm -----

        // user clicked 'logout'
        elmClient.ports.auth0Logout.subscribe(() => {
            this.firebase.auth().signOut();
        });

        // user logged in
        elmClient.ports.firebaseLogin.subscribe(this.login.bind(this));

        // save user ratings to firebase
        elmClient.ports.saveUserRatings.subscribe(this.castVote.bind(this));

        // ----- messages outgoing to elm -----

        // when pokedex loads
        this.votingDb.pokedex.on('value', (data) => {
            const pokedex = data.val();
            elmClient.ports.onLoadPokedex.send(pokedex);
        });

        // when user ratings load (initially: entire team)
        this.votingDb.users.once('value', (data) => {
            const team = data.val();
            elmClient.ports.onLoadTeamRatings.send(team);
        });

        // when user ratings load (when a user votes)
        this.votingDb.users.on('child_changed', (data) => {
            const user = data.val();
            elmClient.ports.onLoadUserRatings.send(user);
        });



    }; // constructor


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

/* vim: set ts=4 sw=4 et list: */
