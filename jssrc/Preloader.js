'use strict';

/** **********************************************************************
 * VotingAppWrapper
 */

module.exports = (function (jQuery) {

    const batchSize = 5;
    const batchTime = 250;
    const imageDir = 'pokeart/';

    /**
     * @param {DOMNode} buttonParentNode
     *   Where the control button should be inserted in the DOM
     *
     * @param {Array} list
     *   List of pokemon to preload, each with properties:
     *     .generation
     *     .imageUrl
     */
    let Preloader = function (buttonParentNode, list)
    {
        this.doPreload = (location.search !== "?nopreload");
        this.list = [];
        this.timer = null;
        this.images = [];
        this.generation = 1;
        this.letter = 'A';
        this.queue(list);
        this.installButton(buttonParentNode);
    };

    Preloader.prototype.installButton = function (parentNode)
    {
        let me = this;
        jQuery(document).ready(function () {
            me.$button = jQuery(parentNode)
                .append('<span id="preload-controls" class="fa"></span>')
                .children()
                .first()
                .on('click', function (e) {
                    me.toggle();
                });
            me.setButton(me.timer ? 'pause' : 'play');
        });
    };

    Preloader.prototype.setButton = function (state)
    {
        if (!this.$button) {
            return;
        }
        if (state === 'play') {
            this.$button.show().addClass('fa-play').removeClass('fa-pause')[0].title = 'resume preloading';
        } else if (state === 'pause') {
            this.$button.show().addClass('fa-pause').removeClass('fa-play')[0].title = 'pause preloading';
        } else {
            this.$button.hide();
        }
    };

    Preloader.prototype.queue = function (list) {
        if (list instanceof Array) {
            this.list = this.list.concat(list);
        }
        this.schedule();
    };

    Preloader.prototype.schedule = function () {
        if (this.doPreload && !this.timer && this.list.length) {
            this.timer = setTimeout(this.preloadImages.bind(this), batchTime);
            this.setButton('pause');
        }
    };

    Preloader.prototype.resume = Preloader.prototype.schedule;

    Preloader.prototype.pause = function ()
    {
        if (this.timer) {
            clearTimeout(this.timer);
            jQuery('.generation-button, .letter_button').removeClass('loading');
            this.timer = null;
            this.setButton('play');
        }
    };

    Preloader.prototype.toggle = function ()
    {
        if (this.timer) {
            this.pause();
        } else {
            this.resume();
        }
    };

    Preloader.prototype.highlightGenerationAndLetterButton = function (state, gen, letter)
    {
        const letterChildIndex = letter.charCodeAt(0) - 64;
        const $buttons = jQuery(
            '.letter-button:nth-child(' + String(letterChildIndex) + '), ' +
            '.generation-button:nth-child(' + String(gen) + ')'
        );
        $buttons.toggleClass('loading', state);
    };

    Preloader.prototype.preloadImages = function ()
    {
        const prevGeneration = this.generation;
        const prevLetter = this.letter;
        for (let i = 0; i < Math.min(batchSize, this.list.length); i += 1) {
            let nextImg = this.list.shift();
            this.generation = nextImg.generation;
            this.letter = nextImg.letter;
            this.images[i] = new Image();
            this.images[i].src = imageDir + nextImg.imageUrl;
        }
        this.highlightGenerationAndLetterButton(false, prevGeneration, prevLetter);
        this.timer = null;
        if (this.list.length) {
            this.highlightGenerationAndLetterButton(true, this.generation, this.letter);
            this.schedule();
        } else {
            this.setButton('hide');
        }
    };

    return Preloader;
})(jQuery);

