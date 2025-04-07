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
    const { service_type, description, scheduled_for, children_ids } = req.body;
    const client_id = req.user.uid;

    // Insert the order into the orders table (no children_ids yet)
    const result = await pool.query(
      "INSERT INTO orders (service_type, description, status, client_id, scheduled_for) VALUES ($1, $2, $3, $4, $5) RETURNING id",
      [service_type, description, "pending", client_id, scheduled_for]
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

router.put("/:id/accept", async (req, res) => {
  const { id } = req.params;
  const { specialist_id } = req.body;

  try {
    const result = await pool.query(
      "UPDATE orders SET status = 'accepted', specialist_id = $1 WHERE id = $2 RETURNING *",
      [specialist_id, id]
    );

    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ error: "Order not found" });
    }
  } catch (error) {
    console.error("Error accepting order:", error);
    res.status(500).json({ error: "Failed to accept order" });
  }
});

router.put("/:id/reject", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      "UPDATE orders SET status = 'rejected' WHERE id = $1 RETURNING *",
      [id]
    );

    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ error: "Order not found" });
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

module.exports = router;
