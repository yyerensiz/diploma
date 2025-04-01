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

module.exports = router;
