
/**
 * Serviceworker for Pokémon Sprint Name Voting Booth
 */

var version = 'v9.9.2';
var cacheName = 'sprintname-voting-booth-' + version;
var filesToCache = [
    '/',
    '/index.html',
    '/bundle.js',
    '/voting-booth.css',
    '/font-awesome.css',
    '/lightbox.css',
    '/lightbox.min.js',
    '/fonts/fontawesome-webfont.woff',
    '/icons/cross.png',
    '/images/lb-close.png',
    '/images/lb-loading.gif',
    '/images/lb-next.png',
    '/images/lb-prev.png',
    '/images/loading-busy.gif',
    '/images/loading-circle.svg',
    '/images/loading-error.png',
    '/images/loading-shade.png',
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
    '/favicons/favicon-512x512.png'
];

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

self.addEventListener('activate', function (event) {
    console.log('[ServiceWorker] Activating');
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
 * Stale-while-revalidate:
 * If found in cache, then send the version from cache.
 * Meanwhile, fetch the new version over the network and cache it.
 *
 * @see https://jakearchibald.com/2014/offline-cookbook/#stale-while-revalidate
 */
self.addEventListener('fetch', function (event) {
    var requestFile = event.request.url.replace(/^https?:\/\/[^\/]+/, '');
    if (filesToCache.indexOf(requestFile) != -1 /* requestFile is in filesToCache ? */
        && event.request.method != 'POST'
    ) {
        event.respondWith(
            caches.open(cacheName).then(function (cache) {
                return cache.match(event.request).then(function (response) {
                    var fetchPromise = fetch(event.request).then(function (networkResponse) {
                        cache.put(event.request, networkResponse.clone());
                        return networkResponse;
                    })
                    return response || fetchPromise;
                });
            })
        );
    }
});

