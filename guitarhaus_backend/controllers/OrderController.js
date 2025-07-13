const asyncHandler = require("../middleware/async");
const Order = require("../models/Order");
const Cart = require("../models/Cart");
const Guitar = require("../models/Guitar");
const { protect, authorize } = require("../middleware/auth");

// @desc    Create new order
// @route   POST /api/v1/orders
// @access  Private
exports.createOrder = asyncHandler(async (req, res, next) => {
  const { shippingAddress, paymentMethod, notes } = req.body;

  // Get user's cart
  const cart = await Cart.findOne({ customer: req.user.id }).populate({
    path: 'items.guitar',
    select: 'name price stock isAvailable'
  });

  if (!cart || cart.items.length === 0) {
    return res.status(400).json({
      success: false,
      message: "Cart is empty"
    });
  }

  // Validate stock and calculate totals
  let subtotal = 0;
  const orderItems = [];

  for (const item of cart.items) {
    const guitar = item.guitar;
    
    if (!guitar.isAvailable) {
      return res.status(400).json({
        success: false,
        message: `${guitar.name} is not available`
      });
    }

    if (guitar.stock < item.quantity) {
      return res.status(400).json({
        success: false,
        message: `Insufficient stock for ${guitar.name}`
      });
    }

    const itemTotal = item.price * item.quantity;
    subtotal += itemTotal;

    orderItems.push({
      guitar: item.guitar._id,
      quantity: item.quantity,
      price: item.price
    });
  }

  // Calculate tax and shipping (you can customize these calculations)
  const tax = subtotal * 0.1; // 10% tax
  const shippingCost = subtotal > 1000 ? 0 : 50; // Free shipping over $1000
  const totalAmount = subtotal + tax + shippingCost;

  // Create order
  const order = await Order.create({
    customer: req.user.id,
    items: orderItems,
    shippingAddress,
    paymentMethod,
    subtotal,
    tax,
    shippingCost,
    totalAmount,
    notes
  });

  // Update guitar stock
  for (const item of cart.items) {
    await Guitar.findByIdAndUpdate(item.guitar._id, {
      $inc: { stock: -item.quantity }
    });
  }

  // Clear cart
  cart.items = [];
  await cart.save();

  // Populate order details
  await order.populate({
    path: 'items.guitar',
    select: 'name brand price images'
  });

  res.status(201).json({
    success: true,
    message: "Order created successfully",
    data: order
  });
});

// @desc    Get user's orders
// @route   GET /api/v1/orders
// @access  Private
exports.getUserOrders = asyncHandler(async (req, res, next) => {
  const orders = await Order.find({ customer: req.user.id })
    .populate({
      path: 'items.guitar',
      select: 'name brand price images'
    })
    .sort('-createdAt');

  res.status(200).json({
    success: true,
    count: orders.length,
    data: orders
  });
});

// @desc    Get single order
// @route   GET /api/v1/orders/:id
// @access  Private
exports.getOrder = asyncHandler(async (req, res, next) => {
  const order = await Order.findById(req.params.id).populate({
    path: 'items.guitar',
    select: 'name brand price images'
  });

  if (!order) {
    return res.status(404).json({
      success: false,
      message: "Order not found"
    });
  }

  // Check if user owns this order or is admin
  if (order.customer.toString() !== req.user.id && req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: "Access denied"
    });
  }

  res.status(200).json({
    success: true,
    data: order
  });
});

// @desc    Get all orders (Admin only)
// @route   GET /api/v1/orders/admin/all
// @access  Private (Admin)
exports.getAllOrders = asyncHandler(async (req, res, next) => {
  if (req.user.role !== "admin") {
    return res.status(403).json({
      success: false,
      message: "Access denied. Admins only."
    });
  }

  const orders = await Order.find()
    .populate({
      path: 'customer',
      select: 'fname lname email'
    })
    .populate({
      path: 'items.guitar',
      select: 'name brand price'
    })
    .sort('-createdAt');

  res.status(200).json({
    success: true,
    count: orders.length,
    data: orders
  });
});

// @desc    Update order status (Admin only)
// @route   PUT /api/v1/orders/:id/status
// @access  Private (Admin)
exports.updateOrderStatus = asyncHandler(async (req, res, next) => {
  if (req.user.role !== "admin") {
    return res.status(403).json({
      success: false,
      message: "Access denied. Admins only."
    });
  }

  const { orderStatus, paymentStatus, trackingNumber, estimatedDelivery } = req.body;

  const order = await Order.findById(req.params.id);

  if (!order) {
    return res.status(404).json({
      success: false,
      message: "Order not found"
    });
  }

  const updateData = {};
  if (orderStatus) updateData.orderStatus = orderStatus;
  if (paymentStatus) updateData.paymentStatus = paymentStatus;
  if (trackingNumber) updateData.trackingNumber = trackingNumber;
  if (estimatedDelivery) updateData.estimatedDelivery = estimatedDelivery;

  const updatedOrder = await Order.findByIdAndUpdate(
    req.params.id,
    updateData,
    { new: true, runValidators: true }
  ).populate({
    path: 'items.guitar',
    select: 'name brand price images'
  });

  res.status(200).json({
    success: true,
    message: "Order status updated successfully",
    data: updatedOrder
  });
});

// @desc    Cancel order
// @route   PUT /api/v1/orders/:id/cancel
// @access  Private
exports.cancelOrder = asyncHandler(async (req, res, next) => {
  const order = await Order.findById(req.params.id);

  if (!order) {
    return res.status(404).json({
      success: false,
      message: "Order not found"
    });
  }

  // Check if user owns this order or is admin
  if (order.customer.toString() !== req.user.id && req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: "Access denied"
    });
  }

  // Only allow cancellation if order is pending or confirmed
  if (!['pending', 'confirmed'].includes(order.orderStatus)) {
    return res.status(400).json({
      success: false,
      message: "Order cannot be cancelled at this stage"
    });
  }

  order.orderStatus = 'cancelled';
  await order.save();

  // Restore stock if order was confirmed
  if (order.orderStatus === 'confirmed') {
    for (const item of order.items) {
      await Guitar.findByIdAndUpdate(item.guitar, {
        $inc: { stock: item.quantity }
      });
    }
  }

  res.status(200).json({
    success: true,
    message: "Order cancelled successfully",
    data: order
  });
}); 