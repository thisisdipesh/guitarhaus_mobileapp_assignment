import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/stripe_payment_service.dart';
import 'dart:ui';
import 'payment_success_screen.dart';
import '../../../../core/common/stripe_webview.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ApiService _apiService = ApiService();
  final StripePaymentService _stripeService = StripePaymentService();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  // Payment method
  String _selectedPaymentMethod = 'Stripe';
  bool _isLoading = false;

  // Shipping cost
  final double _shippingCost = 5.99;
  final double _taxRate = 0.08; // 8% tax

  @override
  void initState() {
    super.initState();
    _initializeAuthToken();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _initializeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _apiService.setAuthToken(token);
      _stripeService.setAuthToken(token);
    }
  }

  Future<void> _loadUserData() async {
    // Load user data from SharedPreferences or API
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('email');
    if (userEmail != null) {
      _emailController.text = userEmail;
    }
  }

  double get _subtotal => widget.totalAmount;
  double get _tax => _subtotal * _taxRate;
  double get _total => _subtotal + _shippingCost + _tax;

  // Enhanced Stripe payment handler
  Future<void> onStripePay() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Process payment using Stripe Payment Service
      final result = await _stripeService.processPayment(_total, 'usd');

      if (result.success) {
        // Payment successful, place order
        await _placeOrder();
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Process subscription payment (for guitars with stripePriceId)
  Future<void> onStripeSubscriptionPay(String priceId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _stripeService.processSubscription(priceId);

      if (result.success && result.checkoutUrl != null) {
        // For subscription payments, we need to handle the checkout URL
        // In a real app, you might want to open this in a WebView
        if (mounted) {
          _showSubscriptionCheckoutDialog(result.checkoutUrl!);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subscription setup failed: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscription error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSubscriptionCheckoutDialog(String checkoutUrl) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF232946),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Complete Subscription',
              style: TextStyle(color: Colors.white, fontFamily: 'Ubuntu-Bold'),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'To complete your subscription, please visit the checkout page.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Text(
                  'Checkout URL:',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  checkoutUrl,
                  style: TextStyle(color: Color(0xFFB799FF), fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFFB799FF)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openStripeWebView(checkoutUrl);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB799FF),
                ),
                child: const Text(
                  'Open Checkout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _openStripeWebView(String checkoutUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => StripeWebView(
              checkoutUrl: checkoutUrl,
              onSuccess: (url) {
                // Handle successful subscription
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subscription completed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
              },
              onCancel: (url) {
                // Handle cancelled subscription
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subscription was cancelled'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
      ),
    );
  }

  // Legacy payment intent method (keeping for backward compatibility)
  Future<Map<String, dynamic>> fetchPaymentIntentClientSecret() async {
    final dio = Dio();
    final response = await dio.post(
      'http://10.0.2.2:5000/api/v1/orders/create-payment-intent',
      data: {
        'amount': _total, // amount in dollars
        'currency': 'usd',
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return {'clientSecret': response.data['clientSecret']};
    } else {
      throw Exception(
        'Failed to create payment intent: ${response.data['message']}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102840),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102840),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontFamily: 'Ubuntu-Bold',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary Section
                _buildOrderSummary(),
                const SizedBox(height: 24),

                // Shipping Details Section
                _buildShippingDetails(),
                const SizedBox(height: 24),

                // Payment Method Section
                _buildPaymentMethod(),
                const SizedBox(height: 24),

                // Total Summary
                _buildTotalSummary(),
                const SizedBox(height: 32),

                // Place Order Button
                _buildPlaceOrderButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232946), Color(0xFF2D1E2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag,
                      color: Color(0xFFB799FF),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Ubuntu-Bold',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...widget.cartItems.map((item) => _buildOrderItem(item)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildItemImage(item['image']),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item['quantity']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('assets/')) {
      if (imagePath.startsWith('http')) {
        return Image.network(
          imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 24, color: Colors.grey),
              ),
        );
      } else {
        return Image.asset(
          imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 24, color: Colors.grey),
              ),
        );
      }
    } else {
      print("IMAGE PATH: $imagePath");
      final imageUrl = 'http://10.0.2.2:5000/uploads/$imagePath';
      return Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 24, color: Colors.grey),
            ),
      );
    }
  }

  Widget _buildShippingDetails() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232946), Color(0xFF2D1E2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFB799FF),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Shipping Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Ubuntu-Bold',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.home,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _stateController,
                  label: 'State',
                  icon: Icons.map,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your state';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                  icon: Icons.pin_drop,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your postal code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _countryController,
                  label: 'Country',
                  icon: Icons.public,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your country';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: const Color(0xFFB799FF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB799FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB799FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232946), Color(0xFF2D1E2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.payment,
                      color: Color(0xFFB799FF),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Ubuntu-Bold',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPaymentOption('Stripe', Icons.credit_card),
                const SizedBox(height: 8),
                _buildPaymentOption('Cash on Delivery', Icons.money),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    final isSelected = _selectedPaymentMethod == method;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFB799FF).withOpacity(0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFFB799FF)
                    : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFB799FF) : Colors.white70,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              method,
              style: TextStyle(
                color: isSelected ? const Color(0xFFB799FF) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFB799FF),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSummary() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232946), Color(0xFF2D1E2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.receipt,
                      color: Color(0xFFB799FF),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Order Total',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Ubuntu-Bold',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTotalRow('Subtotal', _subtotal),
                _buildTotalRow('Shipping', _shippingCost),
                _buildTotalRow('Tax (8%)', _tax),
                const Divider(color: Colors.white30, height: 24),
                _buildTotalRow('Total', _total, isTotal: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? const Color(0xFFFFD700) : Colors.white,
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isTotal ? const Color(0xFFFFD700) : Colors.white,
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    if (_selectedPaymentMethod == 'Stripe') {
      return Column(
        children: [
          // Main Stripe payment button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : onStripePay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB799FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: const Color(0xFFB799FF).withOpacity(0.3),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Pay with Stripe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Ubuntu-Bold',
                        ),
                      ),
            ),
          ),

          // Additional info for Stripe payments
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF232946).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFB799FF).withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Color(0xFFB799FF), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Secure payment powered by Stripe. Your payment information is encrypted and secure.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Cash on Delivery
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB799FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: const Color(0xFFB799FF).withOpacity(0.3),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Place Order (Cash on Delivery)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Ubuntu-Bold',
                      ),
                    ),
          ),
        ),

        // Additional info for COD
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF232946).withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFB799FF).withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.payment, color: Color(0xFFB799FF), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pay when you receive your order. No upfront payment required.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Test backend connectivity first
      final isBackendConnected = await _apiService.testBackendConnection();
      if (!isBackendConnected) {
        throw Exception(
          'Backend server is not accessible. Please check if the server is running.',
        );
      }

      // Create order data - match backend expectations
      final orderData = {
        'shippingAddress': {
          'fullName': _nameController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'postalCode': _postalCodeController.text,
          'country': _countryController.text,
          'phone': _phoneController.text,
        },
        'paymentMethod': 'stripe', // Use 'stripe' as the payment method
        'notes': 'Order placed via mobile app with Stripe payment',
      };

      print('Sending order data: $orderData'); // Debug log

      // Call API to create order
      final response = await _apiService.createOrder(orderData);

      print('Order response status: ${response.statusCode}'); // Debug log
      print('Order response data: ${response.data}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Clear cart after successful order
        await _apiService.clearCart();

        if (mounted) {
          // Navigate to success screen for Stripe payments, show dialog for COD
          if (_selectedPaymentMethod == 'Stripe') {
            final orderId =
                response.data['data']?['_id'] ??
                'ORDER-${DateTime.now().millisecondsSinceEpoch}';
            _navigateToSuccessScreen(orderId);
          } else {
            _showOrderSuccessDialog();
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to place order: ${response.data['message'] ?? 'Unknown error'}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Order creation error: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF232946),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text(
                  'Order Placed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
              ],
            ),
            content: const Text(
              'Your order has been successfully placed. You will receive a confirmation email shortly.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to cart
                },
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(color: Color(0xFFB799FF)),
                ),
              ),
            ],
          ),
    );
  }

  void _navigateToSuccessScreen(String orderId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => PaymentSuccessScreen(
              orderId: orderId,
              amount: _total,
              paymentMethod: _selectedPaymentMethod,
            ),
      ),
    );
  }
}
