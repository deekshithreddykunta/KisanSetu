const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const pool = require("../config/database");

const allowedRoles = [
    "farmer",
    "consumer",
    "buyer",
    "fpo",
    "logistics",
    "admin"
];

const registerUser = async ({ name, email, phone, password, role }) => {
    if (!name || !password || !role) {
        throw new Error("Name, password and role are required");
    }

    if (!allowedRoles.includes(role)) {
        throw new Error("Invalid user role");
    }

    if (!email && !phone) {
        throw new Error("Email or phone is required");
    }

    const existingUser = await pool.query(
        `SELECT id FROM users
         WHERE ($1::text IS NOT NULL AND email = $1)
            OR ($2::text IS NOT NULL AND phone = $2)
         LIMIT 1`,
        [email || null, phone || null]
    );

    if (existingUser.rows.length > 0) {
        throw new Error("User already exists");
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const result = await pool.query(
        `INSERT INTO users
        (name, email, phone, password_hash, role)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id, name, email, phone, role, created_at`,
        [
            name,
            email || null,
            phone || null,
            passwordHash,
            role
        ]
    );

    return result.rows[0];
};

const loginUser = async ({ email, phone, password }) => {
    if ((!email && !phone) || !password) {
        throw new Error("Login credentials are required");
    }

    const result = await pool.query(
        `SELECT *
         FROM users
         WHERE ($1::text IS NOT NULL AND email = $1)
            OR ($2::text IS NOT NULL AND phone = $2)
         LIMIT 1`,
        [email || null, phone || null]
    );

    if (result.rows.length === 0) {
        throw new Error("Invalid credentials");
    }

    const user = result.rows[0];

    const passwordMatch = await bcrypt.compare(
        password,
        user.password_hash
    );

    if (!passwordMatch) {
        throw new Error("Invalid credentials");
    }

    const token = jwt.sign(
        {
            id: user.id,
            role: user.role
        },
        process.env.JWT_SECRET,
        {
            expiresIn: "7d"
        }
    );

    return {
        token,
        user: {
            id: user.id,
            name: user.name,
            email: user.email,
            phone: user.phone,
            role: user.role
        }
    };
};

module.exports = {
    registerUser,
    loginUser
};