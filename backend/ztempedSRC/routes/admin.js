const express = require('express');
const router = express.Router(); // ✅ You missed this line
const pool = require('../database/db'); // ✅ Adjust if your DB connection is elsewhere

// Verify specialist by admin
router.put('/verify-specialist/:userId', async (req, res) => {
    const userId = req.params.userId;
    console.log(`Verifying specialist with userId: ${userId}`);
    try {
        const specialistResult = await pool.query(
            'UPDATE specialist SET verified = true WHERE user_id = $1 RETURNING *',
            [userId]
        );
        console.log('Specialist update result:', specialistResult.rows);

        res.status(200).json({ message: 'Specialist verified successfully' });
    } catch (error) {
        console.error('Error verifying specialist:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});


module.exports = router;
