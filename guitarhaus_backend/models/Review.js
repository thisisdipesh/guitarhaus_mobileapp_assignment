const mongoose = require("mongoose");

const reviewSchema = new mongoose.Schema({
  customer: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: "Customer", 
    required: true 
  },
  guitar: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: "Guitar", 
    required: true 
  },
  rating: { 
    type: Number, 
    required: true, 
    min: 1, 
    max: 5 
  },
  title: { 
    type: String, 
    required: true,
    trim: true,
    maxlength: 100 
  },
  comment: { 
    type: String, 
    required: true,
    trim: true,
    maxlength: 500 
  },
  images: [{ 
    type: String 
  }],
  isVerified: { 
    type: Boolean, 
    default: false 
  },
  helpful: { 
    type: Number, 
    default: 0 
  },
  createdAt: { 
    type: Date, 
    default: Date.now 
  },
  updatedAt: { 
    type: Date, 
    default: Date.now 
  }
});

// Update the updatedAt field before saving
reviewSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Ensure one review per customer per guitar
reviewSchema.index({ customer: 1, guitar: 1 }, { unique: true });

module.exports = mongoose.model("Review", reviewSchema);