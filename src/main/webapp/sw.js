

self.addEventListener('push', function(event) {
    console.log('[Service Worker] Push Received.');
    console.log('[Service Worker] Push had this data:' + event.data);
    console.log('[Service Worker] Push had this data.text:' + event.data.text());

    var title = 'Push Codelab';
    var options = {
        body: 'Yay it works.',
        icon: 'images/icon.png',
        badge: 'images/badge.png'
    };

    event.waitUntil(self.registration.showNotification(title, options));
});


self.addEventListener('notificationclick', function(event) {
    console.log('[Service Worker] Notification click Received.');

    event.notification.close();

    event.waitUntil(
        clients.openWindow('https://developers.google.com/web/')
    );
});