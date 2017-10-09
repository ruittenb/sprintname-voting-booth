
jQuery(document).ready(function () {

    jQuery(document.body).on('click', '.left-arrow', function () {
        const $strip = jQuery(this).next().children('.pokemon-image-strip');
        const variants = +$strip.attr('data-variants');
        let variant = +$strip.attr('data-variant') || 1;
//        variant = variant ? variant : 1;
        variant = (variant > 1) ? variant - 1 : variants;
        $strip.attr('data-variant', variant);
    });
    jQuery(document.body).on('click', '.right-arrow', function () {
        const $strip = jQuery(this).prev().children('.pokemon-image-strip');
        const variants = +$strip.attr('data-variants');
        let variant = +$strip.attr('data-variant') || 1;
//        variant = variant ? variant : 1;
        variant = (variant < variants) ? variant + 1 : 1;
        $strip.attr('data-variant', variant);
    });

});

