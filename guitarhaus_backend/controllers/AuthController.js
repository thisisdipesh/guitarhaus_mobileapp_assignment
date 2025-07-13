const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Customer = require("../models/Customer");

const register = async (req, res) => {
    try {
        const { fname, lname, email, phone, password, role = "customer" } = req.body;

        // Check if user already exists
        const existingCustomer = await Customer.findOne({ email });
        if (existingCustomer) {
            return res.status(400).json({
                success: false,
                message: "User with this email already exists"
            });
        }

        // Create new customer
        const customer = new Customer({
            fname,
            lname,
            email,
            phone,
            password,
            role
        });

        await customer.save();

        res.status(201).json({
            success: true,
            message: "User registered successfully",
            data: {
                id: customer._id,
                fname: customer.fname,
                lname: customer.lname,
                email: customer.email,
                role: customer.role
            }
        });

    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({
            success: false,
            message: "Registration failed",
            error: error.message
        });
    }
};

const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Check if user exists
        const customer = await Customer.findOne({ email });
        if (!customer) {
            return res.status(401).json({
                success: false,
                message: "Invalid email or password"
            });
        }

        // Check password
        const isPasswordValid = await customer.matchPassword(password);
        if (!isPasswordValid) {
            return res.status(401).json({
                success: false,
                message: "Invalid email or password"
            });
        }

        // Generate JWT token
        const token = customer.getSignedJwtToken();

        res.status(200).json({
            success: true,
            message: "Login successful",
            data: {
                token,
                user: {
                    id: customer._id,
                    fname: customer.fname,
                    lname: customer.lname,
                    email: customer.email,
                    role: customer.role
                }
            }
        });

    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            success: false,
            message: "Login failed",
            error: error.message
        });
    }
};

const getCustomer = async (req, res) => {
    try {
        const customer = await Customer.findById(req.params.id).select('-password');
        
        if (!customer) {
            return res.status(404).json({
                success: false,
                message: "Customer not found"
            });
        }

        res.status(200).json({
            success: true,
            data: customer
        });

    } catch (error) {
        console.error('Get customer error:', error);
        res.status(500).json({
            success: false,
            message: "Failed to get customer",
            error: error.message
        });
    }
};

const updateCustomer = async (req, res) => {
    try {
        const { fname, lname, email, phone, image } = req.body;
        
        const customer = await Customer.findByIdAndUpdate(
            req.params.id,
            { fname, lname, email, phone, image },
            { new: true, runValidators: true }
        ).select('-password');

        if (!customer) {
            return res.status(404).json({
                success: false,
                message: "Customer not found"
            });
        }

        res.status(200).json({
            success: true,
            message: "Customer updated successfully",
            data: customer
        });

    } catch (error) {
        console.error('Update customer error:', error);
        res.status(500).json({
            success: false,
            message: "Failed to update customer",
            error: error.message
        });
    }
};

module.exports = {
    login,
    register,
    getCustomer,
    updateCustomer
};