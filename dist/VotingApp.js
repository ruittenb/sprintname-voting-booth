'use strict';

const Preloader  = require('./Preloader.js');
const Elm        = require('../src/Main.elm');

/** **********************************************************************
 * VotingApp
 */

module.exports = (function (jQuery)
{
    /** **********************************************************************
     * Static data
     */
    const preloaderControlNodeId = 'version';
    const appNodeId = 'voting-app-node';

    /** **********************************************************************
     * Constructor
     */
    let VotingApp = function ()
    {
        this.preloader = new Preloader('#' + preloaderControlNodeId);
    };

    /** **********************************************************************
     * GO!
     */
    VotingApp.prototype.run = function ({ idToken, accessToken, profile })
    {
        const appNode = document.getElementById(appNodeId);
        this.elmClient = Elm.Main.embed(appNode, JSON.stringify(storedProfile));

        // preload images as requested by elm
        this.elmClient.ports.preloadImages.subscribe((imageList) => {
            this.preloader.queue(imageList);
        });
    };

    return VotingApp;

})(jQuery);

/* vim: set ts=4 sw=4 et list: */
