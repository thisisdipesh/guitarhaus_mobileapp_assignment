const asyncHandler = require("../middleware/async");
const Guitar = require("../models/Guitar");
const { protect, authorize } = require("../middleware/auth");

// @desc    Get all guitars
// @route   GET /api/v1/guitars
// @access  Public
exports.getGuitars = asyncHandler(async (req, res, next) => {
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 10;
  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const total = await Guitar.countDocuments();

  let query = Guitar.find();

  // Filter by category
  if (req.query.category) {
    query = query.find({ category: req.query.category });
  }

  // Filter by brand
  if (req.query.brand) {
    query = query.find({ brand: req.query.brand });
  }

  // Filter by price range
  if (req.query.minPrice || req.query.maxPrice) {
    const priceFilter = {};
    if (req.query.minPrice) priceFilter.$gte = parseFloat(req.query.minPrice);
    if (req.query.maxPrice) priceFilter.$lte = parseFloat(req.query.maxPrice);
    query = query.find({ price: priceFilter });
  }

  // Filter by availability
  if (req.query.available) {
    query = query.find({ isAvailable: req.query.available === 'true' });
  }

  // Search functionality
  if (req.query.search) {
    query = query.find({
      $text: { $search: req.query.search }
    });
  }

  // Sort
  if (req.query.sort) {
    const sortBy = req.query.sort.split(',');
    const sortOrder = {};
    sortBy.forEach(item => {
      const [field, order] = item.split(':');
      sortOrder[field] = order === 'desc' ? -1 : 1;
    });
    query = query.sort(sortOrder);
  } else {
    query = query.sort('-createdAt');
  }

  query = query.skip(startIndex).limit(limit);

  const guitars = await query.populate('reviews');

  // Pagination result
  const pagination = {};

  if (endIndex < total) {
    pagination.next = {
      page: page + 1,
      limit
    };
  }

  if (startIndex > 0) {
    pagination.prev = {
      page: page - 1,
      limit
    };
  }

  res.status(200).json({
    success: true,
    count: guitars.length,
    pagination,
    data: guitars
  });
});

// @desc    Get single guitar
// @route   GET /api/v1/guitars/:id
// @access  Public
exports.getGuitar = asyncHandler(async (req, res, next) => {
  const guitar = await Guitar.findById(req.params.id).populate('reviews');

  if (!guitar) {
    return res.status(404).json({ 
      success: false, 
      message: `Guitar not found with id ${req.params.id}` 
    });
  }

  res.status(200).json({
    success: true,
    data: guitar
  });
});

// @desc    Create new guitar
// @route   POST /api/v1/guitars
// @access  Private (Admin only)
exports.createGuitar = asyncHandler(async (req, res, next) => {
  if (req.user.role !== "admin") {
    return res.status(403).json({ 
      success: false, 
      message: "Access denied. Admins only." 
    });
  }

  const guitar = await Guitar.create(req.body);

  res.status(201).json({
    success: true,
    data: guitar
  });
});

// @desc    Update guitar
// @route   PUT /api/v1/guitars/:id
// @access  Private (Admin only)
exports.updateGuitar = asyncHandler(async (req, res, next) => {
  if (req.user.role !== "admin") {
    return res.status(403).json({ 
      success: false, 
      message: "Access denied. Admins only." 
    });
  }

  let guitar = await Guitar.findById(req.params.id);

  if (!guitar) {
    return res.status(404).json({ 
      success: false, 
      message: `Guitar not found with id ${req.params.id}` 
    });
  }

  guitar = await Guitar.findByIdAndUpdate(req.params.id, req.body, {
    new: true,
    runValidators: true
  });

  res.status(200).json({
    success: true,
    data: guitar
  });
});

// @desc    Delete guitar
// @route   DELETE /api/v1/guitars/:id
// @access  Private (Admin only)
exports.deleteGuitar = asyncHandler(async (req, res, next) => {
  if (req.user.role !== "admin") {
    return res.status(403).json({ 
      success: false, 
      message: "Access denied. Admins only." 
    });
  }

  const guitar = await Guitar.findById(req.params.id);

  if (!guitar) {
    return res.status(404).json({ 
      success: false, 
      message: `Guitar not found with id ${req.params.id}` 
    });
  }

  await guitar.remove();

  res.status(200).json({
    success: true,
    message: "Guitar deleted successfully"
  });
});

// @desc    Get featured guitars
// @route   GET /api/v1/guitars/featured
// @access  Public
exports.getFeaturedGuitars = asyncHandler(async (req, res, next) => {
  const guitars = await Guitar.find({ isFeatured: true }).limit(10);

  res.status(200).json({
    success: true,
    count: guitars.length,
    data: guitars
  });
});

// @desc    Get guitars by category
// @route   GET /api/v1/guitars/category/:category
// @access  Public
exports.getGuitarsByCategory = asyncHandler(async (req, res, next) => {
  const guitars = await Guitar.find({ category: req.params.category });

  res.status(200).json({
    success: true,
    count: guitars.length,
    data: guitars
  });
});

// @desc    Search guitars
// @route   GET /api/v1/guitars/search
// @access  Public
exports.searchGuitars = asyncHandler(async (req, res, next) => {
  const { q } = req.query;

  if (!q) {
    return res.status(400).json({
      success: false,
      message: "Search query is required"
    });
  }

  const guitars = await Guitar.find({
    $text: { $search: q }
  });

  res.status(200).json({
    success: true,
    count: guitars.length,
    data: guitars
  });
}); 