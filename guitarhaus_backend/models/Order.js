const mongoose = require("mongoose");

const orderSchema = new mongoose.Schema({
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
  shippingAddress: {
    fullName: { type: String, required: true },
    address: { type: String, required: true },
    city: { type: String, required: true },
    state: { type: String, required: true },
    postalCode: { type: String, required: true },
    country: { type: String, required: true },
    phone: { type: String, required: true }
  },
  paymentMethod: { 
    type: String, 
    enum: ["credit-card", "debit-card", "paypal", "cash-on-delivery"], 
    required: true 
  },
  paymentStatus: { 
    type: String, 
    enum: ["pending", "paid", "failed", "refunded"], 
    default: "pending" 
  },
  orderStatus: { 
    type: String, 
    enum: ["pending", "confirmed", "shipped", "delivered", "cancelled"], 
    default: "pending" 
  },
  subtotal: { 
    type: Number, 
    required: true 
  },
  tax: { 
    type: Number, 
    default: 0 
  },
  shippingCost: { 
    type: Number, 
    default: 0 
  },
  totalAmount: { 
    type: Number, 
    required: true 
  },
  trackingNumber: { 
    type: String 
  },
  estimatedDelivery: { 
    type: Date 
  },
  notes: { 
    type: String 
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
orderSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model("Order", orderSchema); 