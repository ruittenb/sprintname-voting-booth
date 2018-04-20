/**
 * Name        : Observable
 * Description : Simple implementation of observable-listener pattern
 * Author      : René Uittenbogaard
 */
const Observable = (function ()
{
    /**
     * Create a constructor function.
     */
    const Observable = function ()
    {
        this.handlers = {};
    };

    /**
     * Fire an event. Find the handlers for this event and execute them.
     *
     * @param String event
     * @param Array arguments
     *   Arguments to be passed to the handlers
     */
    Observable.prototype.fire = function () // event, arguments
    {
        let handler, data = arguments;
        let ev = Array.prototype.shift.call(data);
        for (let i in this.handlers[ev]) {
            this.handlers[ev][i].apply(this, data);
        }
    };

    /**
     * Add a handler.
     *
     * @param String ev
     *   Event to handle
     * @param Function handler
     *   Handler to call when the event is fired
     * @param Object context
     *   Handler's context
     */
    Observable.prototype.on = function (ev, handler, context)
    {
        if (this.handlers[ev] === undefined) {
            this.handlers[ev] = [];
        }
        this.handlers[ev].push(function () {
            handler.apply(context, arguments);
        });
    };

    // return constructor function
    return Observable;

})();

/* vim: set ts=4 sw=4 et list: */
