import api from "./api";

export const registerUser = async (userData) => {
    const response = await api.post("/auth/register", userData);
    return response.data;
};

export const loginUser = async (loginData) => {
    const response = await api.post("/auth/login", loginData);

    if (response.data.token) {
        localStorage.setItem(
            "kisansetu_token",
            response.data.token
        );

        localStorage.setItem(
            "kisansetu_user",
            JSON.stringify(response.data.user)
        );
    }

    return response.data;
};

export const logoutUser = () => {
    localStorage.removeItem("kisansetu_token");
    localStorage.removeItem("kisansetu_user");
};

export const getCurrentUser = () => {
    const user = localStorage.getItem("kisansetu_user");

    return user ? JSON.parse(user) : null;
};