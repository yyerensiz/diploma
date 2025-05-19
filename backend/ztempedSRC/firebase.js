const admin = require("firebase-admin");
//const serviceAccount = require("../firebase-admin-key.json"); 
const serviceAccount = JSON.parse(process.env.FIREBASE_CREDENTIALS);


if (!admin.apps.length) {
  admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
  });
  console.log("Firebase Admin Initialized");
}

module.exports = admin;
