const baseUrl = "https://assets.pokemon.com/assets/cms2/img/pokedex/full/"; //001.png
const maxNum = 802;
const batchSize = 5;
var images = [];

function sprintf3d(num)
{
    var res = String(num);
    if (num < 100) { res = "0" + res; }
    if (num <  10) { res = "0" + res; }
    return res;
}

function generationOf(num)
{
         if (num > 721) { return 7; }
    else if (num > 649) { return 6; }
    else if (num > 493) { return 5; }
    else if (num > 386) { return 4; }
    else if (num > 251) { return 3; }
    else if (num > 151) { return 2; }
    else if (num !=  0) { return 1; }
    return 0;
}

function toggleGenerationButton(state, num)
{
    var generation = generationOf(num);
    var $button = jQuery('.generation-button:nth-child('+String(generation)+')');
    $button.toggleClass('loading', state);
}

function preloadBatch(num)
{
    for (var i = num; i < Math.min(num + batchSize, maxNum); i += 1) {
        images[i] = new Image();
        images[i].src = baseUrl + sprintf3d(i) + ".png";
    }
    toggleGenerationButton(false, num);
    if (num + batchSize < maxNum) {
        toggleGenerationButton(true, num + batchSize);
        setTimeout(function () { preloadBatch(num + batchSize); }, 200);
    }
}

preloadBatch(1);
