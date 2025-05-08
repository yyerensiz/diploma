const express = require('express');
const router = express.Router();
const db = require('../database/db'); 
const pool = require('../database/db'); 
const verifyFirebaseToken = require("../middlewares/authMiddleware");
// or wherever your db connection is

router.get("/", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM children");
    console.log("Children table fetched:", result.rows);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching children table:", error);
    res.status(500).json({ error: "Failed to fetch orders" });
  }
});
// Add a new child
router.post('/', verifyFirebaseToken, async (req, res) => {
    const { full_name, birth_date, pfp_url, bio } = req.body;
    const firebase_id = req.user.uid;
    
    const userResult = await pool.query(
        "SELECT id FROM users WHERE firebase_uid = $1",
        [firebase_id]
    );
    if (userResult.rows.length === 0) {
        return res.status(404).json({ error: "User not found" });
    }
    const client_id = userResult.rows[0].id;
    if (!client_id || !full_name || !birth_date) {
        return res.status(400).json({ error: 'Required fields are missing' });
    }

  try {
    const result = await db.query(
      `INSERT INTO children (client_id, full_name, birth_date, pfp_url, bio)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id`,
      [client_id, full_name, birth_date, pfp_url || null, bio || null]
    );

    res.status(201).json({ child_id: result.rows[0].id });
  } catch (error) {
    console.error('Error inserting child:', error);
    res.status(500).json({ error: 'Failed to add child' });
  }
});
// app.post('/children', async (req, res) => {
//     const { name, birth_date, bio } = req.body;
//     await pool.query(
//       'INSERT INTO children (name, birth_date, bio) VALUES ($1, $2, $3)',
//       [name, birth_date, bio]
//     );
//     res.status(201).send("Child created");
//   });
  

module.exports = router;
