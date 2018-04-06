
jQuery(document).ready(function () {
    $('#version')
        .append('<span id="preload-controls" class="fa fa-pause"></span>')
        .on('click', function (e) {
            jQuery(e.target).toggleClass('fa-pause').toggleClass('fa-play');
            window.preloader ? window.preloader.toggle(): null;
        });
});

