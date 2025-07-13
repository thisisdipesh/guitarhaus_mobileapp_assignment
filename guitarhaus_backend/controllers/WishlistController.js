const asyncHandler = require("../middleware/async");
const Wishlist = require("../models/Wishlist");
const Guitar = require("../models/Guitar");
const { protect } = require("../middleware/auth");

// @desc    Get user's wishlist
// @route   GET /api/v1/wishlist
// @access  Private
exports.getWishlist = asyncHandler(async (req, res, next) => {
  const wishlist = await Wishlist.find({ customer: req.user.id })
    .populate({
      path: 'guitar',
      select: 'name brand price images category isAvailable stock rating'
    })
    .sort('-addedAt');

  res.status(200).json({
    success: true,
    count: wishlist.length,
    data: wishlist
  });
});

// @desc    Add guitar to wishlist
// @route   POST /api/v1/wishlist/add
// @access  Private
exports.addToWishlist = asyncHandler(async (req, res, next) => {
  const { guitarId } = req.body;

  if (!guitarId) {
    return res.status(400).json({
      success: false,
      message: "Guitar ID is required"
    });
  }

  // Check if guitar exists
  const guitar = await Guitar.findById(guitarId);
  if (!guitar) {
    return res.status(404).json({
      success: false,
      message: "Guitar not found"
    });
  }

  // Check if already in wishlist
  const existingWishlist = await Wishlist.findOne({
    customer: req.user.id,
    guitar: guitarId
  });

  if (existingWishlist) {
    return res.status(400).json({
      success: false,
      message: "Guitar already in wishlist"
    });
  }

  const wishlist = await Wishlist.create({
    customer: req.user.id,
    guitar: guitarId
  });

  await wishlist.populate({
    path: 'guitar',
    select: 'name brand price images category isAvailable stock rating'
  });

  res.status(201).json({
    success: true,
    message: "Guitar added to wishlist successfully",
    data: wishlist
  });
});

// @desc    Remove guitar from wishlist
// @route   DELETE /api/v1/wishlist/remove/:guitarId
// @access  Private
exports.removeFromWishlist = asyncHandler(async (req, res, next) => {
  const { guitarId } = req.params;

  const wishlist = await Wishlist.findOneAndDelete({
    customer: req.user.id,
    guitar: guitarId
  });

  if (!wishlist) {
    return res.status(404).json({
      success: false,
      message: "Guitar not found in wishlist"
    });
  }

  res.status(200).json({
    success: true,
    message: "Guitar removed from wishlist successfully"
  });
});

// @desc    Check if guitar is in wishlist
// @route   GET /api/v1/wishlist/check/:guitarId
// @access  Private
exports.checkWishlist = asyncHandler(async (req, res, next) => {
  const { guitarId } = req.params;

  const wishlist = await Wishlist.findOne({
    customer: req.user.id,
    guitar: guitarId
  });

  res.status(200).json({
    success: true,
    isInWishlist: !!wishlist
  });
});

// @desc    Clear wishlist
// @route   DELETE /api/v1/wishlist/clear
// @access  Private
exports.clearWishlist = asyncHandler(async (req, res, next) => {
  await Wishlist.deleteMany({ customer: req.user.id });

  res.status(200).json({
    success: true,
    message: "Wishlist cleared successfully"
  });
});
