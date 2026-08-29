importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCqnSkEr6e4RSoiKPnFvndXJc10O_W77MM',
  appId: '1:959185985485:web:638ee755b6fbb26b6eee84',
  messagingSenderId: '959185985485',
  projectId: 'cowboydodartinc-r162vk',
  authDomain: 'cowboydodartinc-r162vk.firebaseapp.com',
  storageBucket: 'cowboydodartinc-r162vk.firebasestorage.app',
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);

  const notificationTitle = payload.notification?.title || 'New Message';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});