// backend/config/firebase.config.js
const admin = require('firebase-admin');
const serviceAccount = require('../../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  // databaseURL: process.env.FIREBASE_DB_URL,
});

console.log('Firebase Admin Initialized');

module.exports = { firebaseAdmin: admin };
