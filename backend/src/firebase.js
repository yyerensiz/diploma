const admin = require("firebase-admin");
const serviceAccount = require("../firebase-admin-key.json"); 

if (!admin.apps.length) {
  admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
  });
  console.log("Firebase Admin Initialized");
}

module.exports = admin;
