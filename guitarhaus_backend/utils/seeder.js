const mongoose = require("mongoose");
const dotenv = require("dotenv");
const Guitar = require("../models/Guitar");
const Customer = require("../models/Customer");

// Load env vars
dotenv.config({ path: "./config/config.env" });

// Connect to DB
mongoose.connect(process.env.LOCAL_DATABASE_URI);

// Sample guitar data
const guitars = [
  {
    name: "Fender Stratocaster",
    brand: "Fender",
    category: "Electric",
    description: "The iconic electric guitar that has shaped the sound of music for decades. Features a versatile tone with three single-coil pickups.",
    price: 1299.99,
    originalPrice: 1499.99,
    discount: 13,
    images: ["fender_strat_1.jpg", "fender_strat_2.jpg"],
    specifications: {
      body: "Alder",
      neck: "Maple",
      fretboard: "Rosewood",
      pickups: "3 Single-coil",
      bridge: "2-Point Tremolo",
      controls: "Master Volume, 2 Tone Controls",
      color: "Olympic White",
      strings: "9-42"
    },
    stock: 15,
    isAvailable: true,
    isFeatured: true,
    rating: 4.8,
    numReviews: 127,
    tags: ["electric", "fender", "stratocaster", "versatile"],
    warranty: "2 Years"
  },
  {
    name: "Gibson Les Paul Standard",
    brand: "Gibson",
    category: "Electric",
    description: "The legendary Les Paul with rich, warm tones and sustain that goes on forever. Perfect for rock and blues.",
    price: 2499.99,
    originalPrice: 2699.99,
    discount: 7,
    images: ["gibson_lespaul_1.jpg", "gibson_lespaul_2.jpg"],
    specifications: {
      body: "Mahogany with Maple top",
      neck: "Mahogany",
      fretboard: "Rosewood",
      pickups: "2 Humbuckers",
      bridge: "Tune-o-matic",
      controls: "2 Volume, 2 Tone Controls",
      color: "Heritage Cherry Sunburst",
      strings: "10-46"
    },
    stock: 8,
    isAvailable: true,
    isFeatured: true,
    rating: 4.9,
    numReviews: 89,
    tags: ["electric", "gibson", "les paul", "rock"],
    warranty: "Lifetime"
  },
  {
    name: "Martin D-28",
    brand: "Martin",
    category: "Acoustic",
    description: "The standard by which all other acoustic guitars are measured. Rich, full-bodied tone with exceptional projection.",
    price: 3299.99,
    originalPrice: 3499.99,
    discount: 6,
    images: ["martin_d28_1.jpg", "martin_d28_2.jpg"],
    specifications: {
      body: "Solid Sitka Spruce top, Solid East Indian Rosewood back and sides",
      neck: "Select Hardwood",
      fretboard: "Ebony",
      pickups: "None (Acoustic)",
      bridge: "Ebony",
      controls: "None",
      color: "Natural",
      strings: "12-54"
    },
    stock: 12,
    isAvailable: true,
    isFeatured: true,
    rating: 4.7,
    numReviews: 156,
    tags: ["acoustic", "martin", "dreadnought", "folk"],
    warranty: "Limited Lifetime"
  },
  {
    name: "Fender Precision Bass",
    brand: "Fender",
    category: "Bass",
    description: "The original electric bass guitar. Deep, punchy tone that has been the foundation of countless hit records.",
    price: 899.99,
    originalPrice: 999.99,
    discount: 10,
    images: ["fender_pbass_1.jpg", "fender_pbass_2.jpg"],
    specifications: {
      body: "Alder",
      neck: "Maple",
      fretboard: "Rosewood",
      pickups: "1 Split-coil",
      bridge: "4-Saddle",
      controls: "Master Volume, Master Tone",
      color: "3-Color Sunburst",
      strings: "45-105"
    },
    stock: 20,
    isAvailable: true,
    isFeatured: false,
    rating: 4.6,
    numReviews: 203,
    tags: ["bass", "fender", "precision", "foundation"],
    warranty: "2 Years"
  },
  {
    name: "Yamaha C40",
    brand: "Yamaha",
    category: "Classical",
    description: "Perfect for beginners and classical music. Nylon strings provide a warm, mellow tone.",
    price: 149.99,
    originalPrice: 179.99,
    discount: 17,
    images: ["yamaha_c40_1.jpg", "yamaha_c40_2.jpg"],
    specifications: {
      body: "Spruce top, Meranti back and sides",
      neck: "Nato",
      fretboard: "Rosewood",
      pickups: "None",
      bridge: "Rosewood",
      controls: "None",
      color: "Natural",
      strings: "Nylon"
    },
    stock: 35,
    isAvailable: true,
    isFeatured: false,
    rating: 4.4,
    numReviews: 89,
    tags: ["classical", "yamaha", "beginner", "nylon"],
    warranty: "1 Year"
  },
  {
    name: "Kala KA-15S",
    brand: "Kala",
    category: "Ukulele",
    description: "Beautiful soprano ukulele with a bright, cheerful tone. Perfect for Hawaiian music and beyond.",
    price: 59.99,
    originalPrice: 69.99,
    discount: 14,
    images: ["kala_ka15s_1.jpg", "kala_ka15s_2.jpg"],
    specifications: {
      body: "Mahogany",
      neck: "Mahogany",
      fretboard: "Walnut",
      pickups: "None",
      bridge: "Walnut",
      controls: "None",
      color: "Satin Mahogany",
      strings: "Aquila Nylgut"
    },
    stock: 50,
    isAvailable: true,
    isFeatured: false,
    rating: 4.5,
    numReviews: 67,
    tags: ["ukulele", "kala", "soprano", "hawaiian"],
    warranty: "1 Year"
  }
];

// Sample admin user
const adminUser = {
  fname: "Admin",
  lname: "User",
  phone: 1234567890,
  email: "admin@guitarhaus.com",
  password: "admin123",
  role: "admin"
};

// Import data
const importData = async () => {
  try {
    // Clear existing data
    await Guitar.deleteMany();
    await Customer.deleteMany({ email: adminUser.email });

    // Create admin user
    await Customer.create(adminUser);

    // Import guitars
    await Guitar.create(guitars);

    console.log("Data imported successfully");
    process.exit();
  } catch (error) {
    console.error("Error importing data:", error);
    process.exit(1);
  }
};

// Delete data
const destroyData = async () => {
  try {
    await Guitar.deleteMany();
    await Customer.deleteMany();

    console.log("Data destroyed successfully");
    process.exit();
  } catch (error) {
    console.error("Error destroying data:", error);
    process.exit(1);
  }
};

// Handle command line arguments
if (process.argv[2] === "-d") {
  destroyData();
} else {
  importData();
} 