const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const Customer = require('./models/Customer');
require('dotenv').config({ path: './config/config.env' });

// Connect to MongoDB
mongoose.connect(process.env.LOCAL_DATABASE_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const createAdminUser = async () => {
  try {
    // Check if admin user already exists
    const existingAdmin = await Customer.findOne({ email: 'admin@guitarhaus.com' });
    
    if (existingAdmin) {
      console.log('Admin user already exists!');
      console.log('Email: admin@guitarhaus.com');
      console.log('Password: admin123');
      console.log('Role:', existingAdmin.role);
      return;
    }

    // Create admin user
    const adminUser = await Customer.create({
      fname: 'Admin',
      lname: 'User',
      email: 'admin@guitarhaus.com',
      password: 'admin123',
      phone: 1234567890,
      role: 'admin'
    });

    console.log('✅ Admin user created successfully!');
    console.log('Email: admin@guitarhaus.com');
    console.log('Password: admin123');
    console.log('Role: admin');
    console.log('User ID:', adminUser._id);
    
  } catch (error) {
    console.error('Error creating admin user:', error);
  } finally {
    mongoose.connection.close();
  }
};

createAdminUser(); 