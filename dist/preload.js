
const Preloader = (function (jQuery) {

    const batchSize = 5;
    const batchTime = 250;

    let Preloader = function (list)
    {
        this.doPreload = (location.search !== "?nopreload");
        this.list = [];
        this.timer = null;
        this.images = [];
        this.generation = 1;
        this.queue(list);
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
            console.log('new timer: ', this.timer);
        }
    };

    Preloader.prototype.resume = Preloader.prototype.schedule;

    Preloader.prototype.pause = function ()
    {
        if (this.timer) {
            clearTimeout(this.timer);
            jQuery('.generation-button').removeClass('loading');
            this.timer = null;
        }
    };

    Preloader.prototype.highlightGenerationButton = function (state, gen)
    {
        const $button = jQuery('.generation-button:nth-child('+String(gen)+')');
        $button.toggleClass('loading', state);
    };

    Preloader.prototype.preloadImages = function ()
    {
        const prevGeneration = this.generation;
        for (let i = 0; i < Math.min(batchSize, this.list.length); i += 1) {
            nextImg = this.list.shift();
            this.generation = nextImg.generation;
            this.images[i] = new Image();
            this.images[i].src = nextImg.imageUrl;
        }
        this.highlightGenerationButton(false, prevGeneration);
        this.timer = null;
        if (this.list.length) {
            this.highlightGenerationButton(true, this.generation);
            this.schedule();
        }
    };

    return Preloader;
})(jQuery);

