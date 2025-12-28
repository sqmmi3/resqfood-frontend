importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyAZCRbn2zzgJpJ_6rIaJ7B1r3urTDWYaa8",
  authDomain: "resqfood-f1ea7.firebaseapp.com",
  projectId: "resqfood-f1ea7",
  storageBucket: "resqfood-f1ea7.firebasestorage.app",
  messagingSenderId: "1006594396654",
  appId: "1:1006594396654:web:dbb50856745800dbcdfeff",
  measurementId: "G-60Q6NF1TEZ"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Received background message ", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png"
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
