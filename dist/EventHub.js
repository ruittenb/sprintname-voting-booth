'use strict';

const Observable = require('./Observable.js');
require('./Globals.js');

/** **********************************************************************
 * EventHub
 */

module.exports = (function ()
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
     * children are registered and passed events if necessary
     */
    EventHub.prototype.register = function (child, events)
    {
        this.children.push({ child, events });

        let me = this;
        let event, handler, i;

        for (event of events) {
            // Create a handler in a new closure scope.
            // If we didn't do this, all handlers would have the same scope.
            handler = (function (me, event) {
                return function () {
                    console.info('%c' + event.toUpperCase(), 'background-color: #bef'); // TODO

                    let args = Array.prototype.slice.apply(arguments);
                    Array.prototype.unshift.call(args, event);
                    me.fire.apply(me, args);
                };
            })(me, event);
            // now install the handler on the client
            child.on(event, handler);
        }
    };

    return EventHub;

})();

/* vim: set ts=4 sw=4 et list: */
