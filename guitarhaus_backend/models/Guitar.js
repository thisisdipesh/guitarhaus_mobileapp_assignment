const mongoose = require("mongoose");

const guitarSchema = new mongoose.Schema(
  {
    name: { 
      type: String, 
      required: true,
      trim: true 
    },
    brand: { 
      type: String, 
      required: true,
      trim: true 
    },
    category: { 
      type: String, 
      required: true, 
      enum: ["Acoustic", "Electric", "Bass", "Classical", "Ukulele", "Accessories"] 
    },
    description: { 
      type: String, 
      required: true 
    },
    price: { 
      type: Number, 
      required: true,
      min: 0 
    },
    originalPrice: { 
      type: Number,
      min: 0 
    },
    discount: { 
      type: Number, 
      default: 0,
      min: 0,
      max: 100 
    },
    images: [{ 
      type: String, 
      required: true 
    }],
    specifications: {
      body: { type: String },
      neck: { type: String },
      fretboard: { type: String },
      pickups: { type: String },
      bridge: { type: String },
      controls: { type: String },
      color: { type: String },
      strings: { type: String }
    },
    stock: { 
      type: Number, 
      required: true, 
      default: 0,
      min: 0 
    },
    isAvailable: { 
      type: Boolean, 
      default: true 
    },
    isFeatured: { 
      type: Boolean, 
      default: false 
    },
    rating: { 
      type: Number, 
      default: 0,
      min: 0,
      max: 5 
    },
    numReviews: { 
      type: Number, 
      default: 0 
    },
    tags: [{ 
      type: String 
    }],
    warranty: { 
      type: String 
    },
    shippingInfo: {
      weight: { type: Number },
      dimensions: { type: String },
      shippingCost: { type: Number, default: 0 }
    }
  },
  { 
    timestamps: true 
  }
);

// Index for search functionality
guitarSchema.index({ name: 'text', brand: 'text', description: 'text' });

module.exports = mongoose.model("Guitar", guitarSchema); 