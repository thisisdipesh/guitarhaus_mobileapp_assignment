import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_service.dart';
import 'bottom_navigation_screen/cart_screen.dart';
import 'bottom_navigation_screen/favorites_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class FeaturedGuitarsScreen extends StatefulWidget {
  const FeaturedGuitarsScreen({super.key});

  @override
  State<FeaturedGuitarsScreen> createState() => _FeaturedGuitarsScreenState();
}

class _FeaturedGuitarsScreenState extends State<FeaturedGuitarsScreen> {
  List<Map<String, dynamic>> featuredGuitars = [];
  bool isLoading = true;
  String? errorMessage;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeAuthToken();
    _fetchFeaturedGuitars();
  }

  Future<void> _initializeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  Future<void> _fetchFeaturedGuitars() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _apiService.getFeaturedGuitars();
      if (response.statusCode == 200) {
        final items = response.data['data'] as List;
        print('Featured guitars data: $items'); // Debug

        setState(() {
          featuredGuitars =
              items
                  .map(
                    (g) => {
                      'id': g['_id'],
                      'name': g['name'],
                      'brand': g['brand'],
                      'price': g['price'].toString(),
                      'category': g['category'],
                      'images': g['images'],
                      'rating': g['rating']?.toDouble() ?? 0.0,
                      'numReviews': g['numReviews'] ?? 0,
                      'isFeatured': g['isFeatured'] ?? false,
                    },
                  )
                  .toList();
          isLoading = false;
        });

        // Debug: Print processed featured guitars
        for (var guitar in featuredGuitars) {
          print(
            'Featured Guitar: ${guitar['name']}, Images: ${guitar['images']}',
          );
        }
      } else {
        setState(() {
          errorMessage =
              'Failed to load featured guitars: ${response.statusMessage}';
          isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        errorMessage = 'Network error: ${e.message}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Unexpected error: ${e.toString()}';
        isLoading = false;
      });
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
          'Featured Guitars',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontFamily: 'Ubuntu-Bold',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchFeaturedGuitars,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFB799FF)),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchFeaturedGuitars,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB799FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (featuredGuitars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_outline, color: Color(0xFFB799FF), size: 64),
            const SizedBox(height: 16),
            const Text(
              'No Featured Guitars',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for featured guitars!',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB799FF), Color(0xFF8F43EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB799FF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Featured Guitars',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Ubuntu-Bold',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${featuredGuitars.length} premium guitars selected by our experts',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Featured Guitars Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: featuredGuitars.length,
              itemBuilder: (context, index) {
                final guitar = featuredGuitars[index];
                return _buildFeaturedGuitarCard(guitar);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedGuitarCard(Map<String, dynamic> guitar) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232946), Color(0xFF2D1E2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Guitar Image
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildGuitarImage(guitar),
                  ),
                ),
              ),

              // Guitar Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guitar['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Ubuntu-Bold',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guitar['brand'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Ubuntu-Italic',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Rating and Price Row
                    Row(
                      children: [
                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFD700),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              guitar['rating'].toString(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Price
                        Text(
                          '\$${guitar['price']}',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Ubuntu-Bold',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: IconButton(
                            icon: Icon(
                              context.watch<FavoritesProvider>().isFavorite(
                                    guitar['id'],
                                  )
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  context.watch<FavoritesProvider>().isFavorite(
                                        guitar['id'],
                                      )
                                      ? Colors.redAccent
                                      : const Color(0xFFB799FF),
                              size: 20,
                            ),
                            onPressed: () {
                              final provider =
                                  context.read<FavoritesProvider>();
                              if (provider.isFavorite(guitar['id'])) {
                                provider.removeFavorite(guitar['id']);
                              } else {
                                provider.addFavorite(guitar);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: const Icon(
                              Icons.shopping_cart,
                              color: Color(0xFF8F43EE),
                              size: 20,
                            ),
                            onPressed: () => _addToCart(guitar['id']),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuitarImage(Map<String, dynamic> guitar) {
    final images = guitar['images'];
    if (images != null && images is List && images.isNotEmpty) {
      final imageUrl = 'http://10.0.2.2:3000/uploads/${images[0]}';
      print('Featured guitar image URL: $imageUrl'); // Debug
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Featured guitar image loading error: $error');
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 40, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
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
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 40, color: Colors.grey),
            ),
      );
    }
  }

  Future<void> _addToCart(String guitarId) async {
    try {
      final response = await _apiService.addToCart(guitarId, 1);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to cart successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to add to cart: ${response.data['message'] ?? 'Unknown error'}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
