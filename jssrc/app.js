'use strict';

/** **********************************************************************
 * includes
 */

require('./version.js');

// Javascript "bridges" to Auth0, Firebase and the Elm app
const Authentication = require('./Authentication.js');
const Database       = require('./Database.js');
const VotingApp      = require('./VotingApp.js');

/** **********************************************************************
 * Register serviceworker if supported
 */

if ('serviceWorker' in navigator) {
    navigator.serviceWorker
        .register('/service-worker.js')
        .then(function (registration) {
            console.log('Service Worker Registered with scope', registration.scope);
        })
        .catch(function (err) {
            console.log('ServiceWorker registration failed:', err);
        });


    navigator.serviceWorker.onmessage = function (evt) {
        console.log('message received'); // TODO
        var message = JSON.parse(evt.data);

        var isRefresh = message.type === 'refresh';
        var isAsset = message.url.includes('asset');
        var lastETag = localStorage.currentETag;
        var isNew =  lastETag !== message.eTag;

        if (isRefresh && isAsset && isNew) {
            if (lastETag) {
                notice.hidden = false;
            }
            localStorage.currentETag = message.eTag;
        }

        var img = document.querySelector('img');
        caches.open(CACHE)
            .then(function (cache) {
                return cache.match(img.src);
            })
            .then(function (response) {
                return response.blob();
            })
            .then(function (bodyBlob) {
                var url = URL.createObjectURL(bodyBlob);
                img.src = url;
                notice.hidden = true;
            });
    };


    //navigator.serviceWorker
    //    .addEventListener('message', function (event) {
    //        console.log(event.data.message);
    //    });
}

/** **********************************************************************
 * main
 */

const auth = new Authentication();
const credentials = auth.retrieveCredentials();

const votingApp = new VotingApp();
votingApp.run(credentials);
auth.register(votingApp.elmClient);

const database = new Database(votingApp.elmClient);

window.votingApp = votingApp;

/** **********************************************************************
 * fix styling issues with :hover on mobile devices
 *
 * @see https://www.prowebdesign.ro/how-to-deal-with-hover-on-touch-screen-devices/
 */

if ('ontouchstart' in document.documentElement) {
    document.body.classList.remove('no-touch');
}

