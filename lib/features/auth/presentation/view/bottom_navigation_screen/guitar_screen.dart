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
        print('Guitars data: $items'); // Debug: Print the raw data
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
        // Debug: Print processed guitars
        for (var guitar in guitars) {
          print('Guitar: ${guitar['name']}, Images: ${guitar['images']}');
        }
      } else {
        setState(() {
          guitarsError = 'Failed to load guitars: ${response.statusMessage}';
          isGuitarsLoading = false;
        });
      }
    } on DioException {
      setState(() {
        guitarsError = 'Network error';
        isGuitarsLoading = false;
      });
    } catch (e) {
      setState(() {
        guitarsError = 'Unexpected error: ${e.toString()}';
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(guitarsError!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchGuitars,
              child: const Text('Retry'),
            ),
          ],
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
    return Scaffold(
      body: SafeArea(
        // Remove RefreshIndicator to disable pull-to-refresh
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
                        Expanded(
                          child: Padding(
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
                                          // Show SnackBar when added to favorites
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Added to favorites',
                                              ),
                                              backgroundColor: Color(
                                                0xFFB799FF,
                                              ),
                                            ),
                                          );
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
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      // Remove the floatingActionButton Row with debug buttons
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       onPressed: () {
      //         _showDebugInfo();
      //       },
      //       backgroundColor: const Color(0xFF8F43EE),
      //       child: const Icon(Icons.bug_report, color: Colors.white),
      //     ),
      //     const SizedBox(width: 16),
      //     FloatingActionButton(
      //       onPressed: () {
      //         _fetchGuitars();
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(
      //             content: Text('Refreshing guitar list...'),
      //             backgroundColor: Color(0xFFB799FF),
      //           ),
      //         );
      //       },
      //       backgroundColor: const Color(0xFFB799FF),
      //       child: const Icon(Icons.refresh, color: Colors.white),
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildGuitarImage(Map<String, dynamic> guitar) {
    final images = guitar['images'];
    print('DEBUG: Guitar ${guitar['name']} images array: $images');
    if (images != null && images is List && images.isNotEmpty) {
      // Add cache-busting query parameter to always fetch the latest image
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      final imageUrl =
          'http://10.0.2.2:3003/uploads/${images[0]}?v=$cacheBuster';
      print('DEBUG: Guitar ${guitar['name']} image URL: $imageUrl');
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Image loading error for $imageUrl: $error');
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
      print(
        'DEBUG: Guitar ${guitar['name']} has no images, using asset fallback.',
      );
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
      backgroundColor: Colors.transparent,
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
            final images = data['images'] ?? [];
            final specs = data['specifications'] ?? {};
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF232946), Color(0xFF8F43EE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 120,
                        height: 6,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    if (images.isNotEmpty)
                      Center(
                        child: Container(
                          width: 220,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.network(
                              images[0],
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Ubuntu-Bold',
                            ),
                          ),
                        ),
                        Icon(
                          Icons.queue_music,
                          color: Color(0xFFFFD700),
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          color: Color(0xFFB799FF),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data['brand'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontFamily: 'Ubuntu-Italic',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.category,
                          color: Color(0xFFB799FF),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data['category'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '\u20B9${data['price']}',
                          style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Ubuntu-Bold',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if ((data['description'] ?? '').isNotEmpty)
                      Text(
                        data['description'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Ubuntu-Regular',
                        ),
                      ),
                    const SizedBox(height: 18),
                    if (specs.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Specifications',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFFB799FF),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Ubuntu-Bold',
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...specs.entries.map(
                            (entry) =>
                                entry.value != null &&
                                        entry.value.toString().isNotEmpty
                                    ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: Color(0xFFB799FF),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${entry.key[0].toUpperCase()}${entry.key.substring(1)}: ',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              entry.value.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB799FF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Favorite',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            // Add to favorites provider
                            final provider = context.read<FavoritesProvider>();
                            provider.addFavorite({
                              'id': data['_id'],
                              'name': data['name'],
                              'brand': data['brand'],
                              'price': data['price'].toString(),
                              'category': data['category'],
                              'images': data['images'],
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to favorites'),
                                backgroundColor: Color(0xFFB799FF),
                              ),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(
                            Icons.shopping_cart,
                            color: Color(0xFF232946),
                          ),
                          label: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              color: Color(0xFF232946),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            try {
                              final response = await _apiService.addToCart(
                                data['_id'],
                                1,
                              );
                              Navigator.pop(context);
                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to cart'),
                                    backgroundColor: Color(0xFFFFD700),
                                  ),
                                );
                              } else {
                                String errorMsg = 'Failed to add to cart';
                                if (response.data != null &&
                                    response.data['message'] != null) {
                                  errorMsg = response.data['message'];
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMsg),
                                    backgroundColor: const Color(0xFFB799FF),
                                  ),
                                );
                              }
                            } catch (e) {
                              Navigator.pop(context);
                              String errorMsg = 'Failed to add to cart!';
                              if (e is DioException &&
                                  e.response != null &&
                                  e.response?.data != null) {
                                errorMsg =
                                    e.response?.data['message'] ?? errorMsg;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMsg),
                                  backgroundColor: Color(0xFFB799FF),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDebugInfo() {
    final debugInfo = '''
Guitar List Debug Info:
- Total Guitars: ${guitars.length}
- Loading: $isGuitarsLoading
- Error: $guitarsError

Sample Guitar:
${guitars.isNotEmpty ? guitars[0].toString() : 'No guitars loaded.'}
''';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(debugInfo), backgroundColor: Colors.blueGrey),
    );
  }
}
