import { useState } from "react";
import { registerUser } from "../../services/authService";

function Register() {
    const [form, setForm] = useState({
        name: "",
        email: "",
        phone: "",
        password: "",
        role: "farmer"
    });

    const [message, setMessage] = useState("");

    const handleChange = (e) => {
        setForm({
            ...form,
            [e.target.name]: e.target.value
        });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        try {
            const data = await registerUser(form);

            setMessage(data.message);

            setForm({
                name: "",
                email: "",
                phone: "",
                password: "",
                role: "farmer"
            });
        } catch (error) {
            setMessage(
                error.response?.data?.message ||
                "Registration failed"
            );
        }
    };

    return (
        <div>
            <h1>KisanSetu Registration</h1>

            <form onSubmit={handleSubmit}>
                <input
                    name="name"
                    placeholder="Full Name"
                    value={form.name}
                    onChange={handleChange}
                    required
                />

                <br /><br />

                <input
                    type="email"
                    name="email"
                    placeholder="Email"
                    value={form.email}
                    onChange={handleChange}
                />

                <br /><br />

                <input
                    name="phone"
                    placeholder="Phone Number"
                    value={form.phone}
                    onChange={handleChange}
                />

                <br /><br />

                <input
                    type="password"
                    name="password"
                    placeholder="Password"
                    value={form.password}
                    onChange={handleChange}
                    required
                />

                <br /><br />

                <select
                    name="role"
                    value={form.role}
                    onChange={handleChange}
                >
                    <option value="farmer">Farmer</option>
                    <option value="consumer">Consumer</option>
                    <option value="buyer">Bulk Buyer</option>
                    <option value="fpo">FPO</option>
                    <option value="logistics">Logistics Partner</option>
                </select>

                <br /><br />

                <button type="submit">
                    Register
                </button>
            </form>

            {message && <p>{message}</p>}
        </div>
    );
}

export default Register;