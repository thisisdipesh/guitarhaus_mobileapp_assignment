const path = require("path");
const express = require("express");
const dotenv = require("dotenv");
const morgan = require("morgan");
const colors = require("colors");
const connectDB = require("./config/db");
const cookieParser = require("cookie-parser");
const mongoSanitize = require("express-mongo-sanitize"); // for sql injection
const helmet = require("helmet");
const xss = require("xss-clean");
const bodyParser = require("body-parser");
const cors = require("cors");
const app = express();
const fs = require('fs');
require('dotenv').config();


// Configure CORS for mobile app and web app
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or Postman)
    if (!origin) return callback(null, true);
    
    const allowedOrigins = ['http://localhost:3000', 'http://localhost:5000', 'http://localhost:3003'];
    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(null, true); // Allow all origins for development
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
};

app.use(cors(corsOptions));
app.options("*", cors(corsOptions));

// Load env file
dotenv.config({
    path: "./config/config.env",
});

// Connect to database
connectDB();

// Route files
const auth = require("./routes/customer");
const guitars = require("./routes/GuitarRoute");
const cart = require("./routes/CartRoute");
const orders = require("./routes/OrderRoute");
const wishlist = require("./routes/WishlistRoute");
const reviews = require("./routes/ReviewRoute");

// Body parser
app.use(express.json());
app.use(cookieParser());

app.use(bodyParser.json({}));
app.use(bodyParser.urlencoded({ extended: true }));

// Dev logging middleware
if (process.env.NODE_ENV === "development") {
    app.use(morgan("dev"));
}

// Sanitize data
app.use(mongoSanitize());

// Set security headers
app.use(helmet());

// Prevent XSS attacks
app.use(xss());

// Additional CORS headers for mobile app compatibility
app.use((req, res, next) => {
    res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
    res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
    res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');
    next();
});

// Serve static files - this must come before routes
app.use(express.static(path.join(__dirname, 'public')));
app.use('/uploads', express.static(path.join(__dirname, 'public/uploads')));

// Test endpoint to list available images
app.get('/api/v1/test-images', (req, res) => {
  const uploadsDir = path.join(__dirname, 'public/uploads');
  try {
    const files = fs.readdirSync(uploadsDir);
    res.json({ 
      success: true, 
      files: files,
      uploadsPath: uploadsDir,
      exists: fs.existsSync(uploadsDir)
    });
  } catch (error) {
    console.log("HERE WE GO: ", error);
    res.json({ 
      success: false, 
      error: error.message,
      uploadsPath: uploadsDir,
      exists: fs.existsSync(uploadsDir)
    });
  }
});

// Mount routers
app.use("/api/v1/customers", auth);
app.use("/api/v1/guitars", guitars);
app.use("/api/v1/cart", cart);
app.use("/api/v1/orders", orders);
app.use("/api/v1/wishlist", wishlist);
app.use("/api/v1/reviews", reviews);

const PORT = process.env.PORT || 3000;

const server = app.listen(
    PORT,
    '0.0.0.0',
    () => {
        console.log(
            `GuitarHaus Server running in ${process.env.NODE_ENV} mode on port ${PORT}`.yellow.bold
        );
        console.log(`Test images: http://localhost:${PORT}/api/v1/test-images`);
        console.log(`Image example: http://localhost:${PORT}/uploads/IMG-1752931327664.jpg`);
    }
);

// Handle unhandled promise rejections
process.on("unhandledRejection", (err, promise) => {
    console.log(`Error: ${err.message}`.red);
    // Close server & exit process
    server.close(() => process.exit(1));
});