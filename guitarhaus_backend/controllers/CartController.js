const asyncHandler = require("../middleware/async");
const Cart = require("../models/Cart");
const Guitar = require("../models/Guitar");
const { protect } = require("../middleware/auth");

// @desc    Get user's cart
// @route   GET /api/v1/cart
// @access  Private
exports.getCart = asyncHandler(async (req, res, next) => {
  let cart = await Cart.findOne({ customer: req.user.id }).populate({
    path: 'items.guitar',
    select: 'name brand price images stock isAvailable'
  });

  if (!cart) {
    cart = await Cart.create({ customer: req.user.id });
  }

  res.status(200).json({
    success: true,
    data: cart
  });
});

// @desc    Add item to cart
// @route   POST /api/v1/cart/add
// @access  Private
exports.addToCart = asyncHandler(async (req, res, next) => {
  const { guitarId, quantity = 1 } = req.body;

  if (!guitarId) {
    return res.status(400).json({
      success: false,
      message: "Guitar ID is required"
    });
  }

  // Check if guitar exists and is available
  const guitar = await Guitar.findById(guitarId);
  if (!guitar) {
    return res.status(404).json({
      success: false,
      message: "Guitar not found"
    });
  }

  if (!guitar.isAvailable) {
    return res.status(400).json({
      success: false,
      message: "Guitar is not available"
    });
  }

  if (guitar.stock < quantity) {
    return res.status(400).json({
      success: false,
      message: "Insufficient stock"
    });
  }

  let cart = await Cart.findOne({ customer: req.user.id });

  if (!cart) {
    cart = await Cart.create({ customer: req.user.id });
  }

  // Check if item already exists in cart
  const existingItemIndex = cart.items.findIndex(
    item => item.guitar.toString() === guitarId
  );

  if (existingItemIndex > -1) {
    // Update quantity
    cart.items[existingItemIndex].quantity += quantity;
    cart.items[existingItemIndex].price = guitar.price;
  } else {
    // Add new item
    cart.items.push({
      guitar: guitarId,
      quantity,
      price: guitar.price
    });
  }

  await cart.save();

  // Populate guitar details
  await cart.populate({
    path: 'items.guitar',
    select: 'name brand price images stock isAvailable'
  });

  res.status(200).json({
    success: true,
    message: "Item added to cart successfully",
    data: cart
  });
});

// @desc    Update cart item quantity
// @route   PUT /api/v1/cart/update/:itemId
// @access  Private
exports.updateCartItem = asyncHandler(async (req, res, next) => {
  const { quantity } = req.body;
  const { itemId } = req.params;

  if (!quantity || quantity < 1) {
    return res.status(400).json({
      success: false,
      message: "Valid quantity is required"
    });
  }

  const cart = await Cart.findOne({ customer: req.user.id });

  if (!cart) {
    return res.status(404).json({
      success: false,
      message: "Cart not found"
    });
  }

  const itemIndex = cart.items.findIndex(
    item => item._id.toString() === itemId
  );

  if (itemIndex === -1) {
    return res.status(404).json({
      success: false,
      message: "Item not found in cart"
    });
  }

  // Check stock availability
  const guitar = await Guitar.findById(cart.items[itemIndex].guitar);
  if (guitar.stock < quantity) {
    return res.status(400).json({
      success: false,
      message: "Insufficient stock"
    });
  }

  cart.items[itemIndex].quantity = quantity;
  await cart.save();

  await cart.populate({
    path: 'items.guitar',
    select: 'name brand price images stock isAvailable'
  });

  res.status(200).json({
    success: true,
    message: "Cart updated successfully",
    data: cart
  });
});

// @desc    Remove item from cart
// @route   DELETE /api/v1/cart/remove/:itemId
// @access  Private
exports.removeFromCart = asyncHandler(async (req, res, next) => {
  const { itemId } = req.params;

  const cart = await Cart.findOne({ customer: req.user.id });

  if (!cart) {
    return res.status(404).json({
      success: false,
      message: "Cart not found"
    });
  }

  const itemIndex = cart.items.findIndex(
    item => item._id.toString() === itemId
  );

  if (itemIndex === -1) {
    return res.status(404).json({
      success: false,
      message: "Item not found in cart"
    });
  }

  cart.items.splice(itemIndex, 1);
  await cart.save();

  await cart.populate({
    path: 'items.guitar',
    select: 'name brand price images stock isAvailable'
  });

  res.status(200).json({
    success: true,
    message: "Item removed from cart successfully",
    data: cart
  });
});

// @desc    Clear cart
// @route   DELETE /api/v1/cart/clear
// @access  Private
exports.clearCart = asyncHandler(async (req, res, next) => {
  const cart = await Cart.findOne({ customer: req.user.id });

  if (!cart) {
    return res.status(404).json({
      success: false,
      message: "Cart not found"
    });
  }

  cart.items = [];
  await cart.save();

  res.status(200).json({
    success: true,
    message: "Cart cleared successfully",
    data: cart
  });
}); 