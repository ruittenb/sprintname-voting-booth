
const batchSize = 5;
let images = [];
let generation = 1;

function toggleGenerationButton(state, generation)
{
    const $button = jQuery('.generation-button:nth-child('+String(generation)+')');
    $button.toggleClass('loading', state);
}

function preloadImages(list)
{
    const prevGeneration = generation;
    for (let i = 0; i < Math.min(batchSize, list.length); i += 1) {
        nextImg = list.shift();
        generation = nextImg.generation;
        images[i] = new Image();
        images[i].src = nextImg.imageUrl;
    }
    toggleGenerationButton(false, prevGeneration);
    if (list.length) {
        toggleGenerationButton(true, generation);
        setTimeout(function () { preloadImages(list); }, 200);
    }
}


