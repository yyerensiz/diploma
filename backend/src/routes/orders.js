const express = require("express");
const router = express.Router();
const pool = require("../database/db");
const verifyFirebaseToken = require("../middlewares/authMiddleware");



router.get("/", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM orders");
    console.log("Orders fetched:", result.rows);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching orders:", error);
    res.status(500).json({ error: "Failed to fetch orders" });
  }
});

router.post("/", verifyFirebaseToken, async (req, res) => {
  try {
    const { service_type, description, scheduled_for, children_ids, specialist_id } = req.body;
    const firebase_id = req.user.uid;

    // Fetch the corresponding user ID from the users table
    const userResult = await pool.query(
      "SELECT id FROM users WHERE firebase_uid = $1",
      [firebase_id]
    );

    // Check if user exists in the database
    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const client_id = userResult.rows[0].id; // The actual client_id to use in the order

    // Insert the order into the orders table (no children_ids yet)
    const result = await pool.query(
      "INSERT INTO orders (service_type, description, status, client_id, specialist_id, scheduled_for) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id",
      [service_type, description, "pending", client_id, specialist_id, scheduled_for]
    );

    const orderId = result.rows[0].id;

    // Insert each child into the order_children relationship table
    if (children_ids && children_ids.length > 0) {
      const values = children_ids.map(child_id => `(${orderId}, ${child_id})`).join(",");
      await pool.query(`INSERT INTO order_children (order_id, child_id) VALUES ${values}`);
    }

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error("Error inserting order:", error);
    res.status(500).json({ error: "Failed to create order" });
  }
});




router.get("/my-orders", verifyFirebaseToken, async (req, res) => {
    const client_id = req.user.uid;
    try {
        const result = await pool.query(
            "SELECT * FROM orders WHERE client_id = $1",
            [client_id]
        );
        res.status(200).json(result.rows);
    } catch (error) {
        console.error("Error fetching orders:", error);
        res.status(500).json({ error: "Failed to fetch orders" });
    }
});
// Accept order (only specialists can do this)
router.put("/:id/accept", verifyFirebaseToken, async (req, res) => {
  const { id } = req.params;
  const firebaseUid = req.user.uid;

  try {
    // Get user info from database by Firebase UID
    const userResult = await pool.query(
      "SELECT id, role FROM users WHERE firebase_uid = $1",
      [firebaseUid]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = userResult.rows[0];

    if (user.role !== 'specialist') {
      return res.status(403).json({ error: "Only specialists can accept orders" });
    }

    const result = await pool.query(
      `UPDATE orders
       SET status = 'accepted',
           specialist_id = $1,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $2 AND status = 'pending'
       RETURNING *`,
      [user.id, id]
    );

    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ error: "Order not found or already processed" });
    }
  } catch (error) {
    console.error("Error accepting order:", error);
    res.status(500).json({ error: "Failed to accept order" });
  }
});
router.put("/:id/reject", verifyFirebaseToken, async (req, res) => {
  const { id } = req.params;
  const firebaseUid = req.user.uid;

  try {
    const userResult = await pool.query(
      "SELECT id, role FROM users WHERE firebase_uid = $1",
      [firebaseUid]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = userResult.rows[0];

    if (user.role !== 'specialist') {
      return res.status(403).json({ error: "Only specialists can reject orders" });
    }

    const result = await pool.query(
      `UPDATE orders
       SET status = 'rejected',
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $1 AND specialist_id = $2 AND status = 'pending'
       RETURNING *`,
      [id, user.id]
    );

    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ error: "Order not found or already processed" });
    }
  } catch (error) {
    console.error("Error rejecting order:", error);
    res.status(500).json({ error: "Failed to reject order" });
  }
});



router.delete("/:id", async (req, res) => {
  const { id } = req.params;

  try {
    await pool.query("DELETE FROM orders WHERE id = $1", [id]);
    console.log("🗑️ Order deleted:", id);
    res.status(200).json({ message: "Order deleted successfully" });
  } catch (error) {
    console.error("Error deleting order:", error);
    res.status(500).json({ error: "Failed to delete order" });
  }
});


router.get("/specialist-orders", verifyFirebaseToken, async (req, res) => {
  try {
    const firebase_uid = req.user.uid;

    // Get user id from firebase_uid
    const userResult = await pool.query(
      "SELECT id FROM users WHERE firebase_uid = $1",
      [firebase_uid]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const user_id = userResult.rows[0].id;

    // Get specialist id
    const specialistResult = await pool.query(
      "SELECT id FROM specialist WHERE user_id = $1",
      [user_id]
    );

    if (specialistResult.rows.length === 0) {
      return res.status(404).json({ error: "Specialist profile not found" });
    }

    const specialist_id = specialistResult.rows[0].id;

    // Return orders assigned to this specialist
    const ordersResult = await pool.query(
      "SELECT * FROM orders WHERE specialist_id = $1",
      [specialist_id]
    );

    res.status(200).json(ordersResult.rows);
  } catch (error) {
    console.error("Error fetching specialist orders:", error);
    res.status(500).json({ error: "Failed to fetch specialist orders" });
  }
});



module.exports = router;
