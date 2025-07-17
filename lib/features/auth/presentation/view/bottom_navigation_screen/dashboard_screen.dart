import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import '../../../../home/view/HomePage.dart';
import 'package:guitarhaus_mobileapp_assignment/core/network/api_service.dart';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/favorites_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'guitar_screen.dart';
// Removed unused or problematic imports

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  // Guitars list state
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
      print('GUITARS API RESPONSE: ' + response.data.toString());
      if (response.statusCode == 200) {
        final items = response.data['data'] as List;
        setState(() {
          guitars =
              items.map((g) {
                print('Guitar ID: ' + g['_id'].toString());
                print(
                  'Has imageData: ' + (g['imageData'] != null ? 'YES' : 'NO'),
                );
                return {
                  'id': g['_id'],
                  'name': g['name'],
                  'brand': g['brand'],
                  'price': g['price'].toString(),
                  'category': g['category'],
                };
              }).toList();
          isGuitarsLoading = false;
        });
      } else {
        setState(() {
          guitarsError = 'Failed to load guitars: ${response.statusMessage}';
          isGuitarsLoading = false;
        });
      }
    } on DioException catch (e) {
      print('DioException: ' + e.toString());
      setState(() {
        guitarsError = 'Network error';
        isGuitarsLoading = false;
      });
    } catch (e, stack) {
      print('Unexpected error in _fetchGuitars: ' + e.toString());
      print(stack);
      setState(() {
        guitarsError = 'Unexpected error: ' + e.toString();
        isGuitarsLoading = false;
      });
    }
  }

  Widget get guitarsPage =>
      isGuitarsLoading
          ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFB799FF)),
          )
          : guitarsError != null
          ? Center(
            child: Text(
              guitarsError!,
              style: const TextStyle(color: Colors.white70),
            ),
          )
          : guitars.isEmpty
          ? const Center(
            child: Text(
              'No guitars found.',
              style: TextStyle(color: Colors.white70),
            ),
          )
          : SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
              child: ListView.separated(
                itemCount: guitars.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 18),
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
                                    color: Colors.deepPurpleAccent.withOpacity(
                                      0.18,
                                    ),
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
                                          fontSize: 18,
                                          fontFamily: 'Ubuntu-Bold',
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
                                                      .watch<
                                                        FavoritesProvider
                                                      >()
                                                      .isFavorite(guitar['id'])
                                                  ? Colors.redAccent
                                                  : Color(0xFFB799FF),
                                        ),
                                        onPressed: () {
                                          final provider =
                                              context.read<FavoritesProvider>();
                                          if (provider.isFavorite(
                                            guitar['id'],
                                          )) {
                                            provider.removeFavorite(
                                              guitar['id'],
                                            );
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
                                              'Add to cart response: ${response.data}',
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
                                                    backgroundColor:
                                                        const Color(0xFFB799FF),
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
                                                  backgroundColor: Color(
                                                    0xFFB799FF,
                                                  ),
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
            // Robust null and type checks
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
            if (data == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'No details available for this guitar.',
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      'http://10.0.2.2:3000/api/v1/guitars/${data['_id']}/image',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      fontFamily: 'Times New Roman',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['brand'] ?? '',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontFamily: 'Ubuntu-Italic',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.queue_music,
                        color: Color(0xFF8F43EE),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data['category'] ?? '',
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '\$${data['price']}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      fontFamily: 'Ubuntu-Bold',
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (data['description'] != null) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Description:',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['description'],
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (data['specifications'] != null &&
                      data['specifications'] is Map) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Specifications:',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...((data['specifications'] as Map).entries.map<Widget>(
                      (entry) =>
                          entry.value != null &&
                                  entry.value.toString().isNotEmpty
                              ? Text(
                                '${entry.key}: ${entry.value}',
                                style: const TextStyle(color: Colors.black54),
                              )
                              : const SizedBox.shrink(),
                    )),
                    const SizedBox(height: 12),
                  ],
                  if (data['stock'] != null) ...[
                    Text(
                      'Stock:  ${data['stock']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                  if (data['rating'] != null) ...[
                    Text(
                      'Rating: ${data['rating']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                  if (data['numReviews'] != null) ...[
                    Text(
                      'Reviews: ${data['numReviews']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F43EE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 32,
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    label: const Text(
                      'Buy Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Proceed to checkout!'),
                          backgroundColor: Color(0xFF8F43EE),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    // You can keep your logout logic here if needed
    // ...
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (currentIndex) {
      case 0:
        body = const HomePage();
        break;
      case 1:
        body = const FavoritesScreen();
        break;
      case 2:
        body = const GuitarScreen();
        break;
      case 3:
        body = const CartScreen();
        break;
      case 4:
        body = const ProfileScreen();
        break;
      default:
        body = const GuitarScreen();
    }
    return Scaffold(
      backgroundColor: const Color(0xFF18122B),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.queue_music),
            label: "Guitar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _getBody() {
    switch (currentIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const FavoritesScreen();
      case 2:
        return guitarsPage;
      case 3:
        return const CartScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomePage();
    }
  }
}

class _ShimmerIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ShimmerIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: IconButton(icon: Icon(icon, color: color), onPressed: onTap),
        );
      },
    );
  }
}

Widget _buildGuitarImage(dynamic guitarOrImagePath) {
  // If a map is passed, extract id
  String? id;
  if (guitarOrImagePath is Map && guitarOrImagePath['id'] != null) {
    id = guitarOrImagePath['id'];
  } else if (guitarOrImagePath is String) {
    // fallback for old usage
    return Image.asset(
      guitarOrImagePath,
      width: double.infinity,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            height: 70,
            child: const Icon(Icons.image, size: 32, color: Colors.grey),
          ),
    );
  }
  if (id != null) {
    final url = 'http://10.0.2.2:3000/api/v1/guitars/$id/image';
    return Image.network(
      url,
      width: double.infinity,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            height: 70,
            child: const Icon(Icons.image, size: 32, color: Colors.grey),
          ),
    );
  }
  return Container(
    color: Colors.grey[300],
    height: 70,
    child: const Icon(Icons.image, size: 32, color: Colors.grey),
  );
}
