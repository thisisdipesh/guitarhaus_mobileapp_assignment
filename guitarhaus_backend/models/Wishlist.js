const mongoose = require("mongoose");

const wishlistSchema = new mongoose.Schema({
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
  addedAt: { 
    type: Date, 
    default: Date.now 
  }
});

// Ensure unique combination of customer and guitar
wishlistSchema.index({ customer: 1, guitar: 1 }, { unique: true });

module.exports = mongoose.model("Wishlist", wishlistSchema);
