const express = require("express");
const router = express.Router();
const { protect, authorize } = require("../middleware/auth");

const {
  createOrder,
  getUserOrders,
  getOrder,
  getAllOrders,
  updateOrderStatus,
  cancelOrder
} = require("../controllers/OrderController");

// User routes
router.use(protect);
router.post("/", createOrder);
router.get("/", getUserOrders);
router.get("/:id", getOrder);
router.put("/:id/cancel", cancelOrder);

// Admin routes
router.get("/admin/all", authorize("admin"), getAllOrders);
router.put("/:id/status", authorize("admin"), updateOrderStatus);

module.exports = router; 