import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/api_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> wishlistItems = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAuthToken();
    _loadWishlist();
  }

  Future<void> _initializeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  Future<void> _loadWishlist() async {
    try {
      final response = await _apiService.getWishlist();
      if (response.statusCode == 200) {
        final items = response.data['data'] as List;
        
        setState(() {
          wishlistItems = items.map((item) => {
            "id": item['_id'],
            "guitarId": item['guitar']['_id'],
            "name": item['guitar']['name'],
            "brand": item['guitar']['brand'],
            "price": item['guitar']['price'].toDouble(),
            "image": item['guitar']['images']?.isNotEmpty == true 
                ? item['guitar']['images'][0] 
                : "assets/image/bass_guitar.jpg",
            "rating": item['guitar']['rating']?.toDouble() ?? 0.0,
            "category": item['guitar']['category'],
          }).toList();
          isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        errorMessage = 'Failed to load wishlist';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Network error';
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromWishlist(String guitarId) async {
    try {
      await _apiService.removeFromWishlist(guitarId);
      await _loadWishlist(); // Reload wishlist data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove: ${e.response?.data['message'] ?? 'Error'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addToCart(String guitarId) async {
    try {
      await _apiService.addToCart(guitarId, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to cart'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart: ${e.response?.data['message'] ?? 'Error'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF696969),
      appBar: AppBar(
        backgroundColor: const Color(0xFF696969),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Icon(Icons.star, color: Colors.blueAccent, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Favorites',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
          ],
        ),
        actions: [
          if (wishlistItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.white),
              onPressed: () async {
                try {
                  await _apiService.clearWishlist();
                  await _loadWishlist();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Favorites cleared'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } on DioException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to clear: ${e.response?.data['message'] ?? 'Error'}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : wishlistItems.isEmpty
                ? _buildEmptyWishlist()
                : _buildWishlistItems(),
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.star_border, color: Colors.blueAccent, size: 80),
        const SizedBox(height: 20),
        const Text(
          "No favorites",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Ubuntu-Bold',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Your favorite items will appear here.",
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
            backgroundColor: Colors.blueAccent,
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

  Widget _buildWishlistItems() {
    return ListView.builder(
      itemCount: wishlistItems.length,
      itemBuilder: (context, index) {
        final item = wishlistItems[index];
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
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 40, color: Colors.grey),
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
                      const SizedBox(height: 4),
                      Text(
                        item['category'],
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              Text(
                                item['rating'].toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.blue),
                      onPressed: () => _addToCart(item['guitarId']),
                      tooltip: 'Add to cart',
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _removeFromWishlist(item['guitarId']),
                      tooltip: 'Remove from favorites',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}