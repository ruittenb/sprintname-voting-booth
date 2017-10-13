
const Preloader = (function (jQuery) {

    const batchSize = 5;
    const batchTime = 250;

    let Preloader = function (list)
    {
        this.timer = null;
        this.list = list;
        this.images = [];
        this.generation = 1;
        this.schedule();
    };

    Preloader.prototype.schedule = function () {
        this.timer = setTimeout(this.preloadImages.bind(this), batchTime);
    };

    Preloader.prototype.stop = function ()
    {
        if (this.timer) {
            clearTimeout(this.timer);
            this.timer = null;
        }
    };

    Preloader.prototype.toggleGenerationButton = function (state, gen)
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
        this.toggleGenerationButton(false, prevGeneration);
        if (this.list.length) {
            this.toggleGenerationButton(true, this.generation);
            this.schedule();
        }
    };

    return Preloader;
})(jQuery);

