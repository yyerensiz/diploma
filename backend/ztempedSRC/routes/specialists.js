const express = require("express");
const router = express.Router();
const pool = require("../database/db");
const verifyFirebaseToken = require("../middlewares/authMiddleware"); // <-- добавь это


router.get("/", async (req, res) => {
    try {
        // Fetch detailed specialist data with user info
        const result = await pool.query(`
            SELECT 
                s.id AS specialist_id,
                u.full_name,
                u.pfp_url,
                s.bio,
                s.rating,
                s.experience_years,
                s.verified
            FROM specialist s
            JOIN users u ON s.user_id = u.id
        `);

        if (result.rows.length > 0) {
            console.log("Fetched specialists:", result.rows);
        } else {
            console.log("No specialists found.");
        }

        res.status(200).json(result.rows);
    } catch (error) {
        console.error("Error fetching specialists:", error);
        res.status(500).json({ error: "Failed to fetch specialists" });
    }
});



// ... твой / роут

router.get("/profile", verifyFirebaseToken, async (req, res) => {
    const firebaseUid = req.user?.uid;

    if (!firebaseUid) {
        return res.status(401).json({ error: "Unauthorized" });
    }

    try {
        // получаем id из users по uid
        const userResult = await pool.query(
            `SELECT id FROM users WHERE firebase_uid = $1`,
            [firebaseUid]
        );

        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        const userId = userResult.rows[0].id;

        const result = await pool.query(`
            SELECT 
                s.id AS specialist_id,
                u.full_name,
                u.email,
                u.phone,
                u.pfp_url,
                s.bio,
                s.rating,
                s.experience_years,
                s.verified
            FROM specialist s
            JOIN users u ON s.user_id = u.id
            WHERE u.id = $1
        `, [userId]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Specialist not found" });
        }

        res.status(200).json(result.rows[0]);
    } catch (error) {
        console.error("Error fetching specialist profile:", error);
        res.status(500).json({ error: "Failed to fetch profile" });
    }
});

router.put("/profile", verifyFirebaseToken, async (req, res) => {
    const firebaseUid = req.user?.uid;

    if (!firebaseUid) {
        return res.status(401).json({ error: "Unauthorized" });
    }

    const { full_name, bio, pfp_url } = req.body;

    try {
        // Get user.id
        const userResult = await pool.query(
            `SELECT id FROM users WHERE firebase_uid = $1`,
            [firebaseUid]
        );

        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        const userId = userResult.rows[0].id;

        // Обновляем users и specialist
        // Modify the pfp_url logic to treat empty string as null
        const updatedPfpUrl = pfp_url.trim() === "" ? null : pfp_url;

        await pool.query(`
            UPDATE users 
            SET full_name = $1, pfp_url = COALESCE($2, pfp_url) 
            WHERE id = $3
        `, [full_name, updatedPfpUrl, userId]);

          
          await pool.query(`
            UPDATE specialist 
            SET bio = $1 
            WHERE user_id = $2
          `, [bio, userId]);
          

        res.status(200).json({ message: "Profile updated successfully" });
    } catch (error) {
        console.error("Error updating specialist profile:", error);
        res.status(500).json({ error: "Failed to update profile" });
    }
});

const multer = require("multer");
const path = require("path");
const fs = require("fs");

const upload = multer({
    dest: "uploads/",
    limits: { fileSize: 5 * 1024 * 1024 },
});

router.post("/verify", verifyFirebaseToken, upload.fields([
    { name: "id_document", maxCount: 1 },
    { name: "certificate", maxCount: 1 },
]), async (req, res) => {
    const firebaseUid = req.user?.uid;
    if (!firebaseUid) return res.status(401).json({ error: "Unauthorized" });

    const userResult = await pool.query(`SELECT id FROM users WHERE firebase_uid = $1`, [firebaseUid]);
    if (userResult.rows.length === 0) return res.status(404).json({ error: "User not found" });

    const userId = userResult.rows[0].id;

    const idDoc = req.files["id_document"]?.[0];
    const certDoc = req.files["certificate"]?.[0];

    if (!idDoc || !certDoc) {
        return res.status(400).json({ error: "Missing documents" });
    }

    const uploadsDir = path.join(__dirname, "../uploads/verification");
    if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });

    const savePath = (file) =>
        path.join(uploadsDir, `${userId}_${file.fieldname}_${Date.now()}${path.extname(file.originalname)}`);
    
    fs.renameSync(idDoc.path, savePath(idDoc));
    fs.renameSync(certDoc.path, savePath(certDoc));

    console.log(`Verification documents received for user ${userId}`);

    // You could store file paths in DB if needed for admin review
    res.status(200).json({ message: "Documents uploaded successfully" });
});


module.exports = router;
