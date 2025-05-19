// backend/config/firebase.config.js
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK with your service account key
// You should download your service account key JSON file from your Firebase project settings
const serviceAccount = JSON.parse(process.env.FIREBASE_CREDENTIALS);// Replace with the actual path

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  // databaseURL: 'YOUR_FIREBASE_DATABASE_URL' // Only if you're using Realtime Database
});
console.log("Firebase Admin Initialized");


const firebaseAdmin = admin;

module.exports = { firebaseAdmin };