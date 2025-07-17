const express = require("express");
const router = express.Router();
const { protect, authorize } = require("../middleware/auth");

const {
  getGuitars,
  getGuitar,
  createGuitar,
  updateGuitar,
  deleteGuitar,
  getFeaturedGuitars,
  getGuitarsByCategory,
  searchGuitars,
  getGuitarImage
} = require("../controllers/GuitarController");

// Public routes
router.get("/", getGuitars);
router.get("/featured", getFeaturedGuitars);
router.get("/category/:category", getGuitarsByCategory);
router.get("/search", searchGuitars);
router.get("/:id", getGuitar);
router.get("/:id/image", getGuitarImage);

// Admin only routes
router.post("/", protect, authorize("admin"), createGuitar);
router.put("/:id", protect, authorize("admin"), updateGuitar);
router.delete("/:id", protect, authorize("admin"), deleteGuitar);

module.exports = router; 