'use strict';

/** **********************************************************************
 * EventHub
 */

const APP_REQUESTS_STORED_PROFILE = 'app_requests_stored_profile';
const ID_TOKEN_RECEIVED_FROM_AUTH = 'id_token_received_from_auth';
const ID_TOKEN_FOUND_IN_STORAGE   = 'id_token_found_in_storage';
const PROFILE_PROBED_IN_STORAGE   = 'profile_probed_in_storage';
const USER_REQUESTED_LOGIN_DIALOG = 'user_requested_login_dialog';
const USER_REQUESTED_LOGOUT       = 'user_requested_logout';
const USER_AUTHENTICATED          = 'user_authenticated';
const FIREBASE_SIGNIN_FAILED      = 'firebase_signin_failed';
const POKEDEX_LOADED              = 'pokedex_loaded';
const USER_RATINGS_LOADED         = 'user_ratings_loaded';
const USER_VOTES_CAST             = 'user_votes_cast';

const EventHub = (function ()
{
    /** **********************************************************************
     * Constructor
     */
    let EventHub = function ()
    {
        this.children = [];
    };

    /** **********************************************************************
     * inherit Observable, but restore the constructor
     */
    EventHub.prototype = new Observable();
    EventHub.prototype.constructor = EventHub;

    /** **********************************************************************
     * children are registered and fired to if necessary
     */
    EventHub.prototype.register = function (child, fires)
    {
        this.children.push({ child, fires });

        let me = this;

        for (let event in fires) {
            child.on(event, function () {
                me.fire(event, ...arguments);
            });
        }
    };

    return EventHub;

})();

