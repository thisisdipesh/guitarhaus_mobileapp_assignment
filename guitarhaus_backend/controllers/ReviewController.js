const asyncHandler = require("../middleware/async");
const Review = require("../models/Review");
const Guitar = require("../models/Guitar");
const { protect } = require("../middleware/auth");

// @desc    Get reviews for a guitar
// @route   GET /api/v1/guitars/:guitarId/reviews
// @access  Public
exports.getGuitarReviews = asyncHandler(async (req, res, next) => {
  const reviews = await Review.find({ guitar: req.params.guitarId })
    .populate({
      path: 'customer',
      select: 'fname lname'
    })
    .sort('-createdAt');

  res.status(200).json({
    success: true,
    count: reviews.length,
    data: reviews
  });
});

// @desc    Add review to guitar
// @route   POST /api/v1/guitars/:guitarId/reviews
// @access  Private
exports.addReview = asyncHandler(async (req, res, next) => {
  const { rating, title, comment } = req.body;

  // Check if guitar exists
  const guitar = await Guitar.findById(req.params.guitarId);
  if (!guitar) {
    return res.status(404).json({
      success: false,
      message: "Guitar not found"
    });
  }

  // Check if user already reviewed this guitar
  const existingReview = await Review.findOne({
    customer: req.user.id,
    guitar: req.params.guitarId
  });

  if (existingReview) {
    return res.status(400).json({
      success: false,
      message: "You have already reviewed this guitar"
    });
  }

  const review = await Review.create({
    customer: req.user.id,
    guitar: req.params.guitarId,
    rating,
    title,
    comment
  });

  await review.populate({
    path: 'customer',
    select: 'fname lname'
  });

  // Update guitar rating
  const reviews = await Review.find({ guitar: req.params.guitarId });
  const avgRating = reviews.reduce((acc, item) => item.rating + acc, 0) / reviews.length;

  await Guitar.findByIdAndUpdate(req.params.guitarId, {
    rating: avgRating,
    numReviews: reviews.length
  });

  res.status(201).json({
    success: true,
    message: "Review added successfully",
    data: review
  });
});

// @desc    Update review
// @route   PUT /api/v1/reviews/:id
// @access  Private
exports.updateReview = asyncHandler(async (req, res, next) => {
  const { rating, title, comment } = req.body;

  let review = await Review.findById(req.params.id);

  if (!review) {
    return res.status(404).json({
      success: false,
      message: "Review not found"
    });
  }

  // Check if user owns this review
  if (review.customer.toString() !== req.user.id) {
    return res.status(403).json({
      success: false,
      message: "Access denied"
    });
  }

  review = await Review.findByIdAndUpdate(
    req.params.id,
    { rating, title, comment },
    { new: true, runValidators: true }
  );

  await review.populate({
    path: 'customer',
    select: 'fname lname'
  });

  // Update guitar rating
  const reviews = await Review.find({ guitar: review.guitar });
  const avgRating = reviews.reduce((acc, item) => item.rating + acc, 0) / reviews.length;

  await Guitar.findByIdAndUpdate(review.guitar, {
    rating: avgRating,
    numReviews: reviews.length
  });

  res.status(200).json({
    success: true,
    message: "Review updated successfully",
    data: review
  });
});

// @desc    Delete review
// @route   DELETE /api/v1/reviews/:id
// @access  Private
exports.deleteReview = asyncHandler(async (req, res, next) => {
  const review = await Review.findById(req.params.id);

  if (!review) {
    return res.status(404).json({
      success: false,
      message: "Review not found"
    });
  }

  // Check if user owns this review or is admin
  if (review.customer.toString() !== req.user.id && req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: "Access denied"
    });
  }

  await review.remove();

  // Update guitar rating
  const reviews = await Review.find({ guitar: review.guitar });
  const avgRating = reviews.length > 0 
    ? reviews.reduce((acc, item) => item.rating + acc, 0) / reviews.length 
    : 0;

  await Guitar.findByIdAndUpdate(review.guitar, {
    rating: avgRating,
    numReviews: reviews.length
  });

  res.status(200).json({
    success: true,
    message: "Review deleted successfully"
  });
});

// @desc    Get user's reviews
// @route   GET /api/v1/reviews/user
// @access  Private
exports.getUserReviews = asyncHandler(async (req, res, next) => {
  const reviews = await Review.find({ customer: req.user.id })
    .populate({
      path: 'guitar',
      select: 'name brand price images'
    })
    .sort('-createdAt');

  res.status(200).json({
    success: true,
    count: reviews.length,
    data: reviews
  });
});