'use strict';

const firebase = require('firebase');
require('firebase/auth');
require('firebase/database');

/** **********************************************************************
 * Database
 */

module.exports = (function (jQuery, firebase)
{
    /** **********************************************************************
     * Static data
     */
    const tokenserverUrl   = `http://${window.location.hostname}:4202/`;
    const firebaseTokenKey = 'elmVotingApp.firebaseToken';

    /** **********************************************************************
     * Constructor. This only installs the incoming port message listeners.
     */
    let Database = function (elmClient)
    {
        this.elmClient = elmClient;

        // ----- messages incoming from elm -----

        // application is ready for initialization of the database
        this.elmClient.ports.firebaseInit.subscribe(this.init.bind(this));

        // user clicked 'logout'
        this.elmClient.ports.firebaseLogout.subscribe(() => {
            firebase.auth().signOut();
        });

        // user logged in
        this.elmClient.ports.firebaseLoginWithJwtToken.subscribe(this.login.bind(this));

        // save user ratings to firebase
        this.elmClient.ports.saveUserRatings.subscribe(this.castVote.bind(this));
    };

    /** **********************************************************************
     * instantiate and initialize the database
     */
    Database.prototype.init = function (firebaseConfig)
    {
        firebase.initializeApp(firebaseConfig);

        this.votingDb = {
            database: firebase.database(),
            pokedex : firebase.database().ref('pokedex'),
            users   : firebase.database().ref('users')
        };

        this.initListeners();
    };

    /** **********************************************************************
     * instantiate and initialize the outgoing port handlers.
     */
    Database.prototype.initListeners = function ()
    {
        // ----- messages outgoing to elm -----

        // when pokedex loads
        this.votingDb.pokedex.on('value', (data) => {
            const pokedex = data.val();
            this.elmClient.ports.onLoadPokedex.send(pokedex);
        });

        // when user ratings load (initially: entire team)
        this.votingDb.users.once('value', (data) => {
            const team = data.val();
            this.elmClient.ports.onLoadTeamRatings.send(team);
        });

        // when user ratings load (when a user votes)
        this.votingDb.users.on('child_changed', (data) => {
            const user = data.val();
            this.elmClient.ports.onLoadUserRatings.send(user);
        });

    }; // initListeners

    /** **********************************************************************
     * take a JWT token, obtain a firebase token, and log in in firebase
     */
    Database.prototype.login = function (jwtToken)
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
                localStorage.setItem(firebaseTokenKey, firebaseToken);
                return firebase.auth().signInWithCustomToken(firebaseToken);
            })
            .catch(function (e) {
                let status = e.status || 500;
                let message = e.responseJSON ? e.responseJSON.message : (e.message || "Server error");
                setTimeout(function () {
                    me.elmClient.ports.onFirebaseLoginFailed.send({ message, status });
                }, 100);
            });
        return;
    };

    /** **********************************************************************
     * database action: casting votes
     */
    Database.prototype.castVote = function (userRatings)
    {
        // id === null would correspond to a delete request.
        // id should not be null, but let's be defensive here.
        if (userRatings.id !== null) {
            let userRef = this.votingDb.users.child(userRatings.id);
            userRef.set(userRatings);
        }
    };

    return Database;

})(jQuery, firebase);

/* vim: set ts=4 sw=4 et list: */
