const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/auth");

const {
  getWishlist,
  addToWishlist,
  removeFromWishlist,
  checkWishlist,
  clearWishlist
} = require("../controllers/WishlistController");

// All wishlist routes require authentication
router.use(protect);

router.get("/", getWishlist);
router.post("/add", addToWishlist);
router.delete("/remove/:guitarId", removeFromWishlist);
router.get("/check/:guitarId", checkWishlist);
router.delete("/clear", clearWishlist);

module.exports = router;
