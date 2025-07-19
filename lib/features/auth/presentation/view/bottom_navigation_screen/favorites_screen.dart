import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/api_service.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/favorites_provider.dart';

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
    final favoriteGuitars = context.watch<FavoritesProvider>().favoriteGuitars;
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
            // Guitar pick icon for theme
            const Icon(Icons.music_note, color: Color(0xFFFFD700), size: 28),
            const SizedBox(width: 8),
            const Text(
              'Favorites',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontFamily: 'Ubuntu-Bold',
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
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
                        'Failed to clear: \\${e.response?.data['message'] ?? 'Error'}',
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
          // Modern gradient background with subtle guitar overlay
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
            child: Opacity(
              opacity: 0.08,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.music_note, size: 220, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child:
                favoriteGuitars.isEmpty
                    ? _buildEmptyWishlist()
                    : ListView.separated(
                      itemCount: favoriteGuitars.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 18),
                      itemBuilder: (context, index) {
                        final guitar = favoriteGuitars[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Color(0xFFB799FF),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: _buildFavoriteGuitarImage(guitar),
                                ),
                                title: Row(
                                  children: [
                                    const Icon(
                                      Icons.queue_music,
                                      color: Color(0xFFFFD700),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        guitar['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          fontFamily: 'Ubuntu-Bold',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      guitar['brand'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                        fontFamily: 'Ubuntu-Italic',
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Color(0xFFFFD700),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          guitar['rating'].toString(),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '\u20B9${guitar['price']}',
                                          style: const TextStyle(
                                            color: Color(0xFFB799FF),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: Colors.redAccent,
                                      ),
                                      tooltip: 'Remove from favorites',
                                      onPressed:
                                          () => context
                                              .read<FavoritesProvider>()
                                              .removeFavorite(guitar['id']),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_shopping_cart,
                                        color: Color(0xFF8F43EE),
                                      ),
                                      tooltip: 'Add to cart',
                                      onPressed: () => _addToCart(guitar['id']),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_note, color: Color(0xFF8F43EE), size: 90),
          const SizedBox(height: 24),
          const Text(
            "No favorite guitars yet!",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Ubuntu-Bold',
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Tap the heart icon on a guitar to add it to your favorites.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: 'Ubuntu-Italic',
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.explore, color: Color(0xFF232946)),
            label: const Text(
              "Browse Guitars",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF232946),
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
        ],
      ),
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

  Widget _buildFavoriteGuitarImage(Map<String, dynamic> guitar) {
    final images = guitar['images'];
    if (images != null && images is List && images.isNotEmpty) {
      final imageUrl = 'http://10.0.2.2:3000/uploads/${images[0]}';
      return Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Image loading error: $error');
          return Container(
            width: 70,
            height: 70,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 40, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 70,
            height: 70,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB799FF),
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        'assets/image/bass_guitar.jpg',
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              width: 70,
              height: 70,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 40, color: Colors.grey),
            ),
      );
    }
  }
}
