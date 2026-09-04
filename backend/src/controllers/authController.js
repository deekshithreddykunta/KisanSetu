const {
    registerUser,
    loginUser
} = require("../services/authService");

const register = async (req, res) => {
    try {
        const user = await registerUser(req.body);

        res.status(201).json({
            success: true,
            message: "Registration successful",
            user
        });
    } catch (error) {
        console.error("Registration error:", error);

        res.status(400).json({
            success: false,
            message: error.message
        });
    }
};

const login = async (req, res) => {
    try {
        const result = await loginUser(req.body);

        res.status(200).json({
            success: true,
            message: "Login successful",
            ...result
        });
    } catch (error) {
        console.error("Login error:", error);

        res.status(401).json({
            success: false,
            message: error.message
        });
    }
};

module.exports = {
    register,
    login
};