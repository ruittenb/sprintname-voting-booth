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

const cacheName = 'sprintname-voting-booth';

if ('serviceWorker' in navigator) {
    navigator.serviceWorker
        .register('/service-worker.js')
        .then(function (registration) {
            console.log('[Navigator] ServiceWorker registered with scope',
                registration.scope);
        })
        .catch(function (err) {
            console.log('[Navigator] ServiceWorker registration failed:', err);
        });


    navigator.serviceWorker.addEventListener('message', function (event) {
        var message = JSON.parse(event.data);
        console.log('[Navigator] Message received', message);

        const file = message.url.replace(/.*pokeart/, '');

        var img = document.querySelector('img[src$="' + file + '"]');
        // Test whether we found a corresponding image in-document.
        // If not, then we were probably just preloading.
        if (img) {
            caches.open(cacheName)
                .then(function (cache) {
                    return cache.match(img.src);
                })
                .then(function (response) {
                    // Test whether we found cached data for this image.
                    // If not, then why did we get here? Just skip.
                    if (response && response.blob) {
                        return response.blob();
                    } else {
                        throw new Error('No image update was found in the application cache, skipping');
                    }
                })
                .then(function (bodyBlob) {
                    var url = URL.createObjectURL(bodyBlob);
                    img.src = url;
                }, function (e) {
                    console.log(e.message);
                });
        }
    });

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

