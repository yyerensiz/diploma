const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const { Pool } = require("pg");

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

router.post("/register", async (req, res) => {
  const { email, password } = req.body;

  try {
    console.log("Received request to register:", email);

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    console.log("Password hashed successfully"); 

    const result = await pool.query(
      "INSERT INTO users (email, password) VALUES ($1, $2) RETURNING *",
      [email, hashedPassword]
    );

    console.log("User saved in database:", result.rows[0]); 

    res.status(201).json({ message: "User registered", user: result.rows[0] });
  } catch (error) {
    console.error("Register error:", error); 
    res.status(500).json({ error: "Server error" });
  }
});

const verifyFirebaseToken = require("../middlewares/authMiddleware"); // Add this if not already

// Get current user's profile info
router.get("/me", verifyFirebaseToken, async (req, res) => {
  try {
    const firebase_uid = req.user.uid;

    const userResult = await pool.query(
      `SELECT id, full_name, email, phone, role, pfp_url FROM users WHERE firebase_uid = $1`,
      [firebase_uid]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = userResult.rows[0];
    res.status(200).json({
      id: user.id,
      fullName: user.full_name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      profileImageUrl: user.pfp_url || "https://example.com/default-profile.png", // Placeholder URL
      address: "г. Алматы", // Placeholder — update later if needed
      age: 24 // Placeholder — optionally calculate from birthdate if available
    });
  } catch (err) {
    console.error("Error getting user:", err);
    res.status(500).json({ error: "Failed to fetch user data" });
  }
});


module.exports = router;
