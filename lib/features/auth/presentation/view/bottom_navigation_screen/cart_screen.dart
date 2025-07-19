import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/api_service.dart';
import '../checkout_screen.dart';
import 'dart:ui';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  String? errorMessage;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAuthTokenAndLoadCart();
  }

  Future<void> _initializeAuthTokenAndLoadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _apiService.setAuthToken(token);
    }
    await _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final response = await _apiService.getCart();
      if (response.statusCode == 200) {
        final cartData = response.data['data'];
        final items = cartData['items'] as List;

        setState(() {
          cartItems =
              items
                  .map(
                    (item) => {
                      "id": item['_id'],
                      "guitarId": item['guitar']['_id'],
                      "name": item['guitar']['name'],
                      "brand": item['guitar']['brand'],
                      "price": item['price'].toDouble(),
                      "quantity": item['quantity'],
                      "image":
                          item['guitar']['images']?.isNotEmpty == true
                              ? item['guitar']['images'][0]
                              : "assets/image/bass_guitar.jpg",
                    },
                  )
                  .toList();
          totalAmount = cartData['totalAmount']?.toDouble() ?? 0.0;
          isLoading = false;
        });

        // Debug: Print cart items and their image paths
        for (var item in cartItems) {
          print('Cart item: ${item['name']}, Image: ${item['image']}');
        }
      }
    } on DioException {
      setState(() {
        errorMessage = 'Failed to load cart';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Network error';
        isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(String itemId, int newQuantity) async {
    try {
      await _apiService.updateCartItem(itemId, newQuantity);
      await _loadCart(); // Reload cart data
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update quantity: ${e.response?.data['message'] ?? 'Error'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeItem(String itemId) async {
    try {
      await _apiService.removeFromCart(itemId);
      await _loadCart(); // Reload cart data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item removed from cart'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to remove item: ${e.response?.data['message'] ?? 'Error'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearCart() async {
    try {
      await _apiService.clearCart();
      await _loadCart(); // Reload cart data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cart cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to clear cart: ${e.response?.data['message'] ?? 'Error'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102840),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Guitar Theme
            _buildGuitarThemedAppBar(),

            // Main Content
            Expanded(
              child:
                  isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFB799FF),
                        ),
                      )
                      : cartItems.isEmpty
                      ? _buildEmptyCart()
                      : _buildCartItems(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuitarThemedAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232946), Color(0xFF2D1E2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFB799FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.queue_music,
              color: Color(0xFFB799FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Guitar Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu-Bold',
                  ),
                ),
                Text(
                  '${cartItems.length} ${cartItems.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          if (cartItems.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                onPressed: _clearCart,
                tooltip: 'Clear cart',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Guitar-themed empty state
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF232946), Color(0xFF2D1E2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB799FF).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.queue_music,
                        color: Color(0xFFB799FF),
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Your Guitar Cart is Empty",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Ubuntu-Bold',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Time to add some amazing guitars to your collection!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontFamily: 'Ubuntu-Italic',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB799FF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFFB799FF).withOpacity(0.3),
                      ),
                      icon: const Icon(Icons.explore, color: Colors.white),
                      label: const Text(
                        "Discover Guitars",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Ubuntu-Bold',
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Cart Items List
          Expanded(
            child: ListView.separated(
              itemCount: cartItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _buildGuitarCartItem(item);
              },
            ),
          ),

          // Checkout Section
          _buildCheckoutSection(),
        ],
      ),
    );
  }

  Widget _buildGuitarCartItem(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232946), Color(0xFF2D1E2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.08),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Top Row: Image and Details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Guitar Image
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB799FF).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _buildCartItemImage(item['image']),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Guitar Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title with Icon
                            Row(
                              children: [
                                const Icon(
                                  Icons.queue_music,
                                  color: Color(0xFFB799FF),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      fontFamily: 'Ubuntu-Bold',
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Brand
                            Text(
                              item['brand'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontFamily: 'Ubuntu-Italic',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Price
                            Text(
                              '₹${item['price'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                fontFamily: 'Ubuntu-Bold',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bottom Row: Quantity Controls and Remove Button
                  Row(
                    children: [
                      // Quantity Controls
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFB799FF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFB799FF).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Minus Button
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFB799FF,
                                  ).withOpacity(0.2),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Color(0xFFB799FF),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (item['quantity'] > 1) {
                                      _updateQuantity(
                                        item['id'],
                                        item['quantity'] - 1,
                                      );
                                    }
                                  },
                                ),
                              ),

                              // Quantity Display
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    '${item['quantity']}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      fontFamily: 'Ubuntu-Bold',
                                    ),
                                  ),
                                ),
                              ),

                              // Plus Button
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFB799FF,
                                  ).withOpacity(0.2),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Color(0xFFB799FF),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _updateQuantity(
                                      item['id'],
                                      item['quantity'] + 1,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Remove Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 24,
                          ),
                          onPressed: () => _removeItem(item['id']),
                          tooltip: 'Remove from cart',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232946), Color(0xFF2D1E2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            children: [
              // Total Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Ubuntu-Bold',
                    ),
                  ),
                  Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Ubuntu-Bold',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CheckoutScreen(
                              cartItems: cartItems,
                              totalAmount: totalAmount,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB799FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 10,
                    shadowColor: const Color(0xFFB799FF).withOpacity(0.4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_checkout,
                        color: Colors.white,
                        size: 26,
                      ),
                      SizedBox(width: 14),
                      Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Ubuntu-Bold',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemImage(String imagePath) {
    print('Building cart item image with path: $imagePath'); // Debug

    // Helper function to build image widget
    Widget buildImageWidget(String url) {
      return Image.network(
        url,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Image loading error: $error');
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFB799FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.queue_music,
              size: 50,
              color: Color(0xFFB799FF),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFB799FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB799FF),
                strokeWidth: 3,
              ),
            ),
          );
        },
      );
    }

    // Check if the image path is a network URL or asset path
    if (imagePath.startsWith('http') || imagePath.startsWith('assets/')) {
      // If it's already a full URL or asset path, use it as is
      if (imagePath.startsWith('http')) {
        print('Using network image: $imagePath');
        return buildImageWidget(imagePath);
      } else {
        // Asset image
        return Image.asset(
          imagePath,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFB799FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.queue_music,
                size: 50,
                color: Color(0xFFB799FF),
              ),
            );
          },
        );
      }
    } else {
      // Construct the full URL for backend images
      final fullUrl = 'http://10.0.2.2:3000/uploads/$imagePath';
      print('Constructed full URL: $fullUrl');
      return buildImageWidget(fullUrl);
    }
  }
}
