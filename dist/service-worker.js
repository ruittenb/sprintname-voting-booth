
/**
 * Serviceworker for Pokémon Sprint Name Voting Booth
 */

const version = 'v10.9.0';
const cacheName = 'sprintname-voting-booth';
const imageDir = '/pokeart/'
const placeHolder = 'silhouette.png';
const filesToCache = [
    '/',
    '/index.html',
    '/bundle.js',
    '/service-worker.js',
    '/voting-booth.css',
    '/font-awesome.css',
    '/lightbox.css',
    '/lightbox.min.js',
    '/fonts/fontawesome-webfont.woff',
    '/icons/cross.png',
    '/icons/lock-bw.png',
    '/icons/lock-open-bw.png',
    '/images/lb-close.png',
    '/images/lb-loading.gif',
    '/images/lb-next.png',
    '/images/lb-prev.png',
    '/images/loading-busy.gif',
    '/images/loading-circle.svg',
    '/images/loading-error.png',
    '/images/loading-shade.png',
    '/images/ribbon.png',
    '/favicons/apple-touch-icon.png',
    '/favicons/favicon.ico',
    '/favicons/favicon-16x16.png',
    '/favicons/favicon-32x32.png',
    '/favicons/favicon-57x57.png',
    '/favicons/favicon-58x58.png',
    '/favicons/favicon-72x72.png',
    '/favicons/favicon-114x114.png',
    '/favicons/favicon-128x128.png',
    '/favicons/favicon-144x144.png',
    '/favicons/favicon-152x152.png',
    '/favicons/favicon-192x192.png',
    '/favicons/favicon-256x256.png',
    '/favicons/favicon-512x512.png',
    imageDir + placeHolder
];

/**
 * Cache important files when installing
 */
self.addEventListener('install', function (event) {
    console.log('[ServiceWorker] Installing');
    self.skipWaiting();
    event.waitUntil(
        caches.open(cacheName).then(function (cache) {
            console.log('[ServiceWorker] Caching app shell');
            return cache.addAll(filesToCache);
        })
    );
});

/**
 * Remove old caches when activating
 */
self.addEventListener('activate', function (event) {
    console.log('[ServiceWorker] Activating', version);
    event.waitUntil(
        caches.keys().then(function (keyList) {
            return Promise.all(keyList.map(function (key) {
                if (key !== cacheName) {
                    console.log('[ServiceWorker] Removing old cache', key);
                    return caches.delete(key);
                }
            }));
        })
    );
    return self.clients.claim();
});

/**
 * Most non-pokemon images on the site use the 'stale-while-revalidate' strategy:
 * If found in cache, then send the version from cache.
 * Meanwhile, fetch the new version over the network and cache it.
 *
 * @see https://jakearchibald.com/2014/offline-cookbook/#stale-while-revalidate
 *
 * Pokemon images use the 'cache-update-and-refresh' strategy:
 * If found in cache, then send the version from cache, otherwise, send a placeholder.
 * Meanwhile, fetch the new version over the network, cache it and update the image
 * in the rendered document.
 *
 * @see https://serviceworke.rs/strategy-cache-update-and-refresh_demo.html
 */
self.addEventListener('fetch', function (event) {
    if (event.request.method !== 'GET') {
        // We don't handle the request, but don't block it either
        return;
    }
    var requestFile = event.request.url.replace(/^https?:\/\/[^\/]+/, '').replace(/#.*/, '');
    if (filesToCache.indexOf(requestFile) !== -1) {
        // This file should be in the cache
        return cacheThenNetwork(event);
    }
    else if (requestFile.indexOf(imageDir) === 0) {
        // This is an image for which a placeholder should be shown
        return cacheElsePlaceholderThenNetworkAndRefresh(event);
    }
    // In all other cases: just don't block the default
});

/**
 * All important framework files are served from the cache first,
 * while the cache is refreshed.
 */
function cacheThenNetwork(event) {
    console.log('[ServiceWorker] cacheThenNetwork', event.request.url);
    event.respondWith(
        caches.open(cacheName).then(function (cache) {
            return cache.match(event.request).then(function (cacheResponse) {
                var fetchPromise = fetch(event.request).then(function (networkResponse) {
                    cache.put(event.request, networkResponse.clone());
                    return networkResponse;
                }).catch(sendCachedFallback);
                return cacheResponse || fetchPromise;
            });
        })
    );
}

/**
 * All artwork images are served from the network only, but if
 * unreachable, serve a placeholder image from the cache.
 */
function cacheElsePlaceholderThenNetworkAndRefresh(event) {
    console.log('[ServiceWorker] cacheElsePlaceholderThenNetworkAndRefresh', event.request.url);
    const firstResponse = fromCache(event.request);
    console.warn('[ServiceWorker] first response', firstResponse);
    event.respondWith(firstResponse.then(function (a) { return a; }));
    event.waitUntil(
        fromNetwork(event.request).then(refreshClients)
    );
}

/**
 * Find an image in the cache and serve it.
 */
function fromCache(request) {
    console.log('[ServiceWorker] fromCache', request.url);
    return caches.open(cacheName).then(function (cache) {
        return cache.match(request);
    }, sendCachedFallback)
        .catch(sendCachedFallback);
}

/**
 * Serve a placeholder image from the cache.
 */
function sendCachedFallback() {
    console.log('[ServiceWorker] sendCachedFallback');
    return fromCache(imageDir + placeHolder);
}

/**
 * Fetch a file from the network.
 */
function fromNetwork(request) {
    console.log('[ServiceWorker] fromNetwork', request.url);
    return caches.open(cacheName).then(function (cache) {
        return fetch(request).then(function (response) {
            return cache.put(request, response.clone()).then(function () {
                return response;
            }).catch(sendCachedFallback);
        });
    });
}

/**
 * Take the image that was retrieved over the network and post it
 * to the client for update
 */
function refreshClients(response) {
    console.log('[ServiceWorker] refreshClients', response);
    return self.clients.matchAll().then(function (clients) {
        clients.forEach(function (client) {
            var message = {
                type: 'refresh',
                url: response.url,
                eTag: response.headers.get('ETag')
            };
            console.log('[ServiceWorker] Sending received image to client...');
            client.postMessage(JSON.stringify(message));
        });
    });
}
