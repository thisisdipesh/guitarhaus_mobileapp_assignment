const mongoose = require("mongoose");

const cartSchema = new mongoose.Schema({
  customer: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: "Customer", 
    required: true 
  },
  items: [{
    guitar: { 
      type: mongoose.Schema.Types.ObjectId, 
      ref: "Guitar", 
      required: true 
    },
    quantity: { 
      type: Number, 
      required: true, 
      min: 1 
    },
    price: { 
      type: Number, 
      required: true 
    }
  }],
  totalAmount: { 
    type: Number, 
    default: 0 
  },
  itemCount: { 
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
cartSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Calculate total amount and item count before saving
cartSchema.pre('save', function(next) {
  this.totalAmount = this.items.reduce((total, item) => {
    return total + (item.price * item.quantity);
  }, 0);
  
  this.itemCount = this.items.reduce((count, item) => {
    return count + item.quantity;
  }, 0);
  
  next();
});

module.exports = mongoose.model("Cart", cartSchema); 