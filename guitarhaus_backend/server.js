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

app.use(cors());
app.options("*", cors());
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
app.use((req, res, next) => {
    res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
    res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
    res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');
    next();
});

// Set static folder
app.use(express.static(path.join(__dirname, 'public')));
// Explicitly serve uploads directory for compatibility with mobile/emulator
app.use('/uploads', express.static(path.join(__dirname, 'public/uploads')));

// Debug middleware to log static file requests
app.use('/uploads', (req, res, next) => {
  console.log(`Static file request: ${req.method} ${req.url}`);
  // Add CORS headers for static files
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  next();
});

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
    }
);

// Handle unhandled promise rejections
process.on("unhandledRejection", (err, promise) => {
    console.log(`Error: ${err.message}`.red);
    // Close server & exit process
    server.close(() => process.exit(1));
});