import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guitarhaus_mobileapp_assignment/core/network/api_service.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/cart_screen.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/favorites_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class GuitarScreen extends StatefulWidget {
  const GuitarScreen({super.key});

  @override
  State<GuitarScreen> createState() => _GuitarScreenState();
}

class _GuitarScreenState extends State<GuitarScreen> {
  List<Map<String, dynamic>> guitars = [];
  bool isGuitarsLoading = false;
  String? guitarsError;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeAuthToken();
    _fetchGuitars();
  }

  Future<void> _initializeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  Future<void> _fetchGuitars() async {
    setState(() {
      isGuitarsLoading = true;
      guitarsError = null;
    });
    try {
      final response = await _apiService.getGuitars(limit: 1000);
      if (response.statusCode == 200) {
        final items = response.data['data'] as List;
        setState(() {
          guitars =
              items
                  .map(
                    (g) => {
                      'id': g['_id'],
                      'name': g['name'],
                      'brand': g['brand'],
                      'price': g['price'].toString(),
                      'category': g['category'],
                      'images': g['images'], // include images array
                    },
                  )
                  .toList();
          isGuitarsLoading = false;
        });
      } else {
        setState(() {
          guitarsError = 'Failed to load guitars: \\${response.statusMessage}';
          isGuitarsLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        guitarsError = 'Network error';
        isGuitarsLoading = false;
      });
    } catch (e) {
      setState(() {
        guitarsError = 'Unexpected error: \\${e.toString()}';
        isGuitarsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isGuitarsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFB799FF)),
      );
    }
    if (guitarsError != null) {
      return Center(
        child: Text(
          guitarsError!,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }
    if (guitars.isEmpty) {
      return const Center(
        child: Text(
          'No guitars found.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: ListView.separated(
          itemCount: guitars.length,
          separatorBuilder: (context, index) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final guitar = guitars[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF232946), Color(0xFF2D1E2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Guitar Image
                      Container(
                        width: 110,
                        height: 110,
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurpleAccent.withOpacity(0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _buildGuitarImage(guitar),
                        ),
                      ),
                      // Details and Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
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
                            const SizedBox(height: 4),
                            Text(
                              guitar['brand'] ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontFamily: 'Ubuntu-Italic',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.queue_music,
                                  color: Color(0xFFB799FF),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  guitar['category'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '\u20B9${guitar['price']}',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Ubuntu-Bold',
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    context
                                            .watch<FavoritesProvider>()
                                            .isFavorite(guitar['id'])
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        context
                                                .watch<FavoritesProvider>()
                                                .isFavorite(guitar['id'])
                                            ? Colors.redAccent
                                            : Color(0xFFB799FF),
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
                                  tooltip:
                                      context
                                              .watch<FavoritesProvider>()
                                              .isFavorite(guitar['id'])
                                          ? 'Remove from favorites'
                                          : 'Add to favorites',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.shopping_cart,
                                    color: Color(0xFF8F43EE),
                                  ),
                                  onPressed: () async {
                                    try {
                                      final response = await _apiService
                                          .addToCart(guitar['id'], 1);
                                      print(
                                        'Add to cart response: \\${response.data}',
                                      );
                                      if (response.statusCode == 200 ||
                                          response.statusCode == 201) {
                                        if (mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const CartScreen(),
                                            ),
                                          );
                                        }
                                      } else {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to add to cart: '
                                                '${response.data['message'] ?? 'Unknown error'}',
                                              ),
                                              backgroundColor: const Color(
                                                0xFFB799FF,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Failed to add to cart!',
                                            ),
                                            backgroundColor: Color(0xFFB799FF),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  tooltip: 'Add to cart',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.visibility,
                                    color: Color(0xFFB799FF),
                                  ),
                                  onPressed:
                                      () => _showQuickView(
                                        context,
                                        guitar,
                                        index,
                                      ),
                                  tooltip: 'Quick view',
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
          },
        ),
      ),
    );
  }

  Widget _buildGuitarImage(Map<String, dynamic> guitar) {
    final images = guitar['images'];
    if (images != null && images is List && images.isNotEmpty) {
      // Adjust the URL to match your backend's image serving route
      final imageUrl = 'http://10.0.2.2:3000/' + images[0];
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 40, color: Colors.grey),
            ),
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

  Future<void> _showQuickView(
    BuildContext context,
    Map<String, dynamic> guitar,
    int index,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.95),
      isScrollControlled: true,
      builder: (context) {
        return FutureBuilder(
          future: _apiService.getGuitar(guitar['id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Could not load details. Please try again.',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.data == null ||
                (snapshot.data as Response).data == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'No data found for this guitar.',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            final data = (snapshot.data as Response).data['data'];
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['brand'] ?? '',
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category: \\${data['category'] ?? ''}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: \\u20B9\\${data['price']}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['description'] ?? '',
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
