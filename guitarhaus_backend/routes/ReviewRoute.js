const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/auth");

const {
  getGuitarReviews,
  addReview,
  updateReview,
  deleteReview,
  getUserReviews
} = require("../controllers/ReviewController");

// Public routes
router.get("/guitar/:guitarId", getGuitarReviews);

// Protected routes
router.use(protect);
router.post("/guitar/:guitarId", addReview);
router.put("/:id", updateReview);
router.delete("/:id", deleteReview);
router.get("/user", getUserReviews);

module.exports = router;
