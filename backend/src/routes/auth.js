const express = require("express");
const router = express.Router();
const pool = require("../database/db");

router.post("/sync", async (req, res) => {
  const { firebase_uid, email, full_name, phone } = req.body;

  try {
      const userExists = await pool.query(
          "SELECT * FROM users WHERE firebase_uid = $1",
          [firebase_uid]
      );

      if (userExists.rows.length === 0) {
        const newUser = await pool.query(
            "INSERT INTO users (firebase_uid, email, full_name, phone, role) VALUES ($1, $2, $3, $4, 'client') RETURNING *",
            [firebase_uid, email, full_name, phone]
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

router.get("/sync", (req, res) => {
  res.status(200).json({ message: "Auth Sync API is working!" });
});

module.exports = router;
