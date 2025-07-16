import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/api_service.dart';
import 'dart:ui';

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
          wishlistItems =
              items
                  .map(
                    (item) => {
                      "id": item['_id'],
                      "guitarId": item['guitar']['_id'],
                      "name": item['guitar']['name'],
                      "brand": item['guitar']['brand'],
                      "price": item['guitar']['price'].toDouble(),
                      "image":
                          item['guitar']['images']?.isNotEmpty == true
                              ? item['guitar']['images'][0]
                              : "assets/image/bass_guitar.jpg",
                      "rating": item['guitar']['rating']?.toDouble() ?? 0.0,
                      "category": item['guitar']['category'],
                    },
                  )
                  .toList();
          isLoading = false;
        });
      }
    } on DioException {
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
          content: Text(
            'Failed to remove: ${e.response?.data['message'] ?? 'Error'}',
          ),
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
          content: Text(
            'Failed to add to cart: ${e.response?.data['message'] ?? 'Error'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Icon(Icons.star, color: Color(0xFFB799FF), size: 26),
            const SizedBox(width: 8),
            const Text(
              'Favorites',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Ubuntu-Bold',
                letterSpacing: 1.2,
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
                      content: Text(
                        'Failed to clear: ${e.response?.data['message'] ?? 'Error'}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF18122B), Color(0xFF8F43EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFB799FF),
                        ),
                      ),
                    )
                    : wishlistItems.isEmpty
                    ? _buildEmptyWishlist()
                    : _buildWishlistItems(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.star_border, color: Color(0xFFB799FF), size: 80),
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
          "Your favorite guitars will appear here.",
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
            backgroundColor: const Color(0xFF8F43EE),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.explore, color: Colors.white),
          label: const Text(
            "Browse Guitars",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      item['image'],
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    item['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      fontFamily: 'Ubuntu',
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['brand'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            ' ${item['price']}',
                            style: const TextStyle(
                              color: Color(0xFFB799FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            item['rating'].toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Color(0xFF8F43EE),
                        ),
                        tooltip: 'Add to Cart',
                        onPressed: () => _addToCart(item['guitarId']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: 'Remove',
                        onPressed: () => _removeFromWishlist(item['guitarId']),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
