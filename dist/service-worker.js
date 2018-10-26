
var version = 'v8.6.3'
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

self.addEventListener('install', function (e) {
    console.log('[ServiceWorker] Installing');
    e.waitUntil(
        caches.open(cacheName).then(function (cache) {
            console.log('[ServiceWorker] Caching app shell');
            return cache.addAll(filesToCache);
        })
    );
});

self.addEventListener('activate', function (e) {
    console.log('[ServiceWorker] Activating');
    e.waitUntil(
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

self.addEventListener('fetch', function (e) {
    console.log('[ServiceWorker] Fetching', e.request.url);
    e.respondWith(
        caches.match(e.request).then(function (response) {
            return response || fetch(e.request);
        })
    );
});

