const express = require("express");
const router = express.Router();
const { protect, authorize } = require("../middleware/auth");

const {
  createOrder,
  getUserOrders,
  getMyOrders,
  getOrder,
  getAllOrders,
  updateOrderStatus,
  cancelOrder,
  createPaymentIntent
} = require("../controllers/OrderController");

// User routes
router.use(protect);
router.post("/", createOrder);
router.post('/create-payment-intent', createPaymentIntent);
router.get("/my-orders", getMyOrders); // Place specific route first
router.get("/", getUserOrders);
router.get("/:id", getOrder);
router.put("/:id/cancel", cancelOrder);

// Admin routes
router.get("/admin/all", authorize("admin"), getAllOrders);
router.put("/:id/status", authorize("admin"), updateOrderStatus);

module.exports = router; 