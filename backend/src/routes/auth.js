const express = require("express");
const router = express.Router();
const pool = require("../database/db");
const authenticateToken = require("../middlewares/authMiddleware"); // или путь к твоему файлу
const getUserByFirebaseUID = async (firebase_uid) => {
  const result = await pool.query("SELECT * FROM users WHERE firebase_uid = $1", [firebase_uid]);
  return result.rows[0]; // Assuming the query returns one user or null if not found
};

router.post("/sync", async (req, res) => {
  const { firebase_uid, email, full_name, phone, fcm_token, role } = req.body;

  try {
      const userExists = await pool.query(
          "SELECT * FROM users WHERE firebase_uid = $1",
          [firebase_uid]
      );

      if (userExists.rows.length === 0) {
        const newUser = await pool.query(
            "INSERT INTO users (firebase_uid, email, full_name, phone, fcm_token, role) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *",
            [firebase_uid, email, full_name, phone, fcm_token, role]
        );
        console.log("✅ New user created:", newUser.rows[0]);
        return res.status(201).json(newUser.rows[0]); // ✅ already correct here
    } else {
        console.log("✅ User already exists:", userExists.rows[0]);
        return res.status(200).json(userExists.rows[0]); // ✅ FIXED HERE
    }
    
  } catch (error) {
      console.error("❌ Error syncing user:", error);
      res.status(500).json({ error: "Failed to sync user" });
  }
  console.log("Received Firebase User Data:", userRecord);

});

// router.get("/sync", (req, res) => {
//   res.status(200).json({ message: "Auth Sync API is working!" });
// });

router.get("/me", authenticateToken, async (req, res) => {
  try {
    const user = await getUserByFirebaseUID(req.user.uid);
    if (!user) return res.status(404).json({ error: "User not found" });
    res.status(200).json(user); // should include role
  } catch (err) {
    console.error("Error:", err); // Log the full error object
    res.status(500).json({ error: "Internal server error" });
  }
});


module.exports = router;
