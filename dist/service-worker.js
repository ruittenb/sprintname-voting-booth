
var version = 'v9.2';
var cacheName = 'sprintname-voting-booth-' + version;
var filesToCache = [
    '/',
    '/index.html',
//    '/app.js',
    '/voting-booth.css',
    '/lightbox.css',
    '/lightbox.min.js',
    '/images/lb-close.png',
    '/images/lb-loading.gif',
    '/images/lb-next.png',
    '/images/lb-prev.png',
    '/images/loading-busy.gif',
    '/images/loading-circle.svg',
    '/images/loading-error.png',
    '/images/loading-shade.png',
    '/icons/cross.png',
];

self.addEventListener('install', function (event) {
    console.log('[ServiceWorker] Installing');
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
    if (filesToCache.indexOf(requestFile) != -1) {
        event.respondWith(
            caches.open(cacheName).then(function (cache) {
                return cache.match(event.request).then(function (response) {
                    console.log('[ServiceWorker] Fetching', event.request.url);
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

