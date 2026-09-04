const express = require("express");
const cors = require("cors");
require("dotenv").config();

const pool = require("./config/database");
const authRoutes = require("./routes/authRoutes");

const app = express();
const {
    authenticateToken,
    authorizeRoles
} = require("./middleware/authMiddleware");
app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
    res.json({
        success: true,
        message: "KisanSetu Backend is running"
    });
});

app.get("/api/health", async (req, res) => {
    try {
        const result = await pool.query("SELECT NOW()");

        res.json({
            success: true,
            message: "KisanSetu API and PostgreSQL are connected",
            databaseTime: result.rows[0].now
        });
    } catch (error) {
        console.error("Database connection failed:", error);

        res.status(500).json({
            success: false,
            message: "Database connection failed"
        });
    }
});
app.get(
    "/api/protected",
    authenticateToken,
    (req, res) => {
        res.json({
            success: true,
            message: "Protected route accessed successfully",
            user: req.user
        });
    }
);
app.get(
    "/api/farmer/test",
    authenticateToken,
    authorizeRoles("farmer"),
    (req, res) => {
        res.json({
            success: true,
            message: "Farmer-only route accessed successfully",
            user: req.user
        });
    }
);
app.use("/api/auth", authRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`KisanSetu Backend running on port ${PORT}`);
});
