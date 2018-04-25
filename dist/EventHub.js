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
     * children are registered and fired to if necessary
     */
    EventHub.prototype.register = function (child, fires)
    {
        this.children.push({ child, fires });

        let me = this;
        let event, i;

        for (i in fires) {
            event = fires[i];
            child.on(event, function () {
                me.fire(event, ...arguments);
            });
        }
    };

    return EventHub;

})();

/* vim: set ts=4 sw=4 et list: */
