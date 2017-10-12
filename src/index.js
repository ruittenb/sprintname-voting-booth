'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');

require('./index.html'); // ensure index.html gets copied during build

let Elm = require('./Main.elm');
let votingApp = Elm.Main.fullscreen();

votingApp.ports.preloadImages.subscribe(preloadImages);

