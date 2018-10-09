'use strict';

const Preloader  = require('./Preloader.js');
const Elm        = require('../src/Main.elm');

/** **********************************************************************
 * VotingApp
 */

module.exports = (function ()
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
    VotingApp.prototype.run = function (credentials)
    {
        const appNode = document.getElementById(appNodeId);
        this.elmClient = Elm.Main.embed(appNode, credentials);

        // preload images as requested by elm
        this.elmClient.ports.preloadImages.subscribe((imageList) => {
            this.preloader.queue(imageList);
        });
    };

    return VotingApp;

})();

/* vim: set ts=4 sw=4 et list: */
