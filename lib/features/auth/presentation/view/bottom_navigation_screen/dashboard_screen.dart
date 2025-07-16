import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import '../../../../home/view/HomePage.dart';
import 'package:guitarhaus_mobileapp_assignment/core/network/api_service.dart';
import 'dart:ui';

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
    _fetchGuitars();
  }

  Future<void> _fetchGuitars() async {
    setState(() {
      isGuitarsLoading = true;
      guitarsError = null;
    });
    try {
      final response = await _apiService.getGuitars();
      print('GUITARS API RESPONSE: ' + response.data.toString());
      if (response.statusCode == 200) {
        final items = response.data['data'] as List;
        setState(() {
          guitars =
              items
                  .map(
                    (g) => {
                      'name': g['name'],
                      'brand': g['brand'],
                      'price': g['price'].toString(),
                      'image':
                          g['images']?.isNotEmpty == true
                              ? g['images'][0]
                              : 'assets/image/guitarhaus.png',
                      'category': g['category'],
                    },
                  )
                  .toList();
          isGuitarsLoading = false;
        });
      } else {
        setState(() {
          guitarsError = 'Failed to load guitars.';
          isGuitarsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        guitarsError = 'Network error.';
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
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 32),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.68, // Slightly taller cards
                          ),
                      itemCount: guitars.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final guitar = guitars[index];
                        return Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF232946), Color(0xFF2D1E2F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Color(0xFF8F43EE),
                              width: 2.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF8F43EE).withOpacity(0.10),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Stack(
                              children: [
                                BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical:
                                        10, // Slightly reduced vertical padding
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          child: Image.asset(
                                            guitar['image'],
                                            width: double.infinity,
                                            height: 70, // Reduced image height
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      color: Colors.grey[300],
                                                      height: 70,
                                                      child: const Icon(
                                                        Icons.image,
                                                        size: 32,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        guitar['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          fontFamily: 'Times New Roman',
                                          letterSpacing: 0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        guitar['brand'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          fontFamily: 'Ubuntu-Italic',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.queue_music,
                                            color: Color(0xFFB799FF),
                                            size: 15,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            guitar['category'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF8F43EE,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                              ),
                                              onPressed: () {
                                                // TODO: Implement add to cart logic
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Added to cart!',
                                                    ),
                                                    backgroundColor: Color(
                                                      0xFF8F43EE,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'Add to Cart',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          AnimatedScale(
                                            scale: 1.0,
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: _ShimmerIconButton(
                                              icon: Icons.visibility,
                                              color: Color(0xFFB799FF),
                                              onTap:
                                                  () => _showQuickView(
                                                    context,
                                                    guitar,
                                                    index,
                                                  ),
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );

  void _showQuickView(
    BuildContext context,
    Map<String, dynamic> guitar,
    int index,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.7),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.60,
          minChildSize: 0.45,
          maxChildSize: 0.90,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
                gradient: const LinearGradient(
                  colors: [Color(0xFF18122B), Color(0xFF2D1E2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF8F43EE).withOpacity(0.22),
                    blurRadius: 32,
                    offset: const Offset(0, -10),
                  ),
                ],
                border: Border.all(color: Color(0xFF8F43EE), width: 2.2),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.asset(
                                guitar['image'],
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 200,
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                            if (index == 0)
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(
                                      0xFFEE6C4D,
                                    ).withOpacity(0.92), // vibrant orange
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Text(
                                    'Best Seller',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            if (index == 1)
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(
                                      0xFFB799FF,
                                    ).withOpacity(0.92), // vibrant purple
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.album,
                                        color: Color(0xFF5CE1E6),
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Classic',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          guitar['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            fontFamily: 'Times New Roman',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          guitar['brand'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
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
                              color: Color(0xFFB799FF),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              guitar['category'] ?? '',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '\$${guitar['price']}',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            fontFamily: 'Ubuntu-Bold',
                          ),
                        ),
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
                          icon: const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Buy Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          onPressed: () {
                            // TODO: Implement buy now logic
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
                  ),
                ),
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
    return Scaffold(
      backgroundColor: const Color(0xFF18122B), // Modern dark background
      resizeToAvoidBottomInset: false, // Prevent bottom overflow
      drawer: Drawer(
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF18122B), Color(0xFF8F43EE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurpleAccent.withOpacity(0.4),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/image/guitarhaus.png',
                          height: 48,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.music_note,
                                color: Colors.white,
                                size: 40,
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'GuitarHaus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Ubuntu',
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Menu',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.queue_music,
                    color: Color(0xFFB799FF),
                  ),
                  title: const Text(
                    'Guitars',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      currentIndex = 2;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, color: Color(0xFFB799FF)),
                  title: const Text(
                    'Favorites',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      currentIndex = 1;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.reviews, color: Color(0xFFB799FF)),
                  title: const Text(
                    'Reviews',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor: const Color(0xFF232946),
                            title: const Text(
                              'Reviews',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Reviews section coming soon!',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(color: Color(0xFFB799FF)),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.shopping_cart,
                    color: Color(0xFFB799FF),
                  ),
                  title: const Text(
                    'Cart',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      currentIndex = 3;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFFB799FF)),
                  title: const Text(
                    'Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      currentIndex = 4;
                    });
                    Navigator.pop(context);
                  },
                ),
                const Divider(
                  color: Colors.white24,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: _logout,
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8F43EE),
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: Row(
          children: [
            Image.asset('assets/image/guitarhaus.png', height: 38),
            const SizedBox(width: 10),
            const Text(
              'Guitarhaus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF8F43EE),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.queue_music),
            label: "Guitars",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
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
