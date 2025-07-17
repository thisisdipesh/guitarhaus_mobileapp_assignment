import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/api_service.dart';

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
      appBar: AppBar(
        backgroundColor: const Color(0xFF102840),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Icon(
              Icons.shopping_cart,
              color: Colors.greenAccent,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
          ],
        ),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.white),
              onPressed: _clearCart,
              tooltip: 'Clear cart',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : cartItems.isEmpty
                ? _buildEmptyCart()
                : _buildCartItems(),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(
          Icons.remove_shopping_cart,
          color: Colors.greenAccent,
          size: 80,
        ),
        const SizedBox(height: 20),
        const Text(
          "The Cart is Empty",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Ubuntu-Bold',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "There is Nothing in the cart.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white70,
            fontFamily: 'Ubuntu-italic',
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.explore, color: Colors.black),
          label: const Text(
            "Browse Products",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Ubuntu-Bold',
            ),
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
      ],
    );
  }

  Widget _buildCartItems() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item['image'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['brand'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '\$${item['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
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
                                    Text(
                                      '${item['quantity']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () {
                                        _updateQuantity(
                                          item['id'],
                                          item['quantity'] + 1,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(item['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to checkout
                    // You can implement checkout functionality later
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
