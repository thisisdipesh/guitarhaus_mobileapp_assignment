import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import '../../../../home/view/HomePage.dart';
import 'package:guitarhaus_mobileapp_assignment/core/network/api_service.dart';

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

  Widget get guitarsPage => Container(
    color: Colors.transparent,
    child:
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
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: guitars.length,
              itemBuilder: (context, index) {
                final guitar = guitars[index];
                return Card(
                  color: const Color(0xFF232946),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        guitar['image'],
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      guitar['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guitar['brand'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
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
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Text(
                      guitar['price'],
                      style: const TextStyle(
                        color: Color(0xFFB799FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
  );

  Future<void> _logout() async {
    // You can keep your logout logic here if needed
    // ...
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18122B), // Modern dark background
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
