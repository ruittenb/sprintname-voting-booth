const baseUrl = "https://assets.pokemon.com/assets/cms2/img/pokedex/full/"; //001.png
const maxNum = 802;
const batchSize = 1;
var images = [];

function sprintf3d(num)
{
    var res = String(num);
    if (num < 100) { res = "0" + res; }
    if (num <  10) { res = "0" + res; }
    return res;
}

function preloadBatch(num)
{
    for (var i = num; i < Math.min(num + batchSize, maxNum); i += 1) {
        images[i] = new Image();
        images[i].src = baseUrl + sprintf3d(num) + ".png";
    }
    if (num + batchSize < maxNum) {
        setTimeout(function () { preloadBatch(num + batchSize); }, 200);
    }
}

preloadBatch(1);
