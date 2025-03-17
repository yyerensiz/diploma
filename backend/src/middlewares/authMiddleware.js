const admin = require("../firebase"); 

const verifyFirebaseToken = async (req, res, next) => {
    const token = req.headers.authorization?.split("Bearer ")[1];

    if (!token) {
        return res.status(401).json({ error: "Unauthorized: No token provided" });
    }

    try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        req.user = decodedToken; 
        console.log("Decoded Firebase Token:", decodedToken);
        next();
    } catch (error) {
        console.error("Firebase Auth Error:", error.message);
        return res.status(403).json({ error: "Unauthorized: Invalid token" });
    }
};

module.exports = verifyFirebaseToken;
