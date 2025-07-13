import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/api_service.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> featuredProducts = [];
  bool isLoading = true;
  String? errorMessage;

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.music_note, "label": "Electric", "category": "Electric"},
    {"icon": Icons.music_note_outlined, "label": "Acoustic", "category": "Acoustic"},
    {"icon": Icons.music_note_rounded, "label": "Bass", "category": "Bass"},
    {"icon": Icons.music_note_sharp, "label": "Classical", "category": "Classical"},
    {"icon": Icons.music_note, "label": "Ukulele", "category": "Ukulele"},
  ];

  @override
  void initState() {
    super.initState();
    _loadFeaturedGuitars();
    _initializeAuthToken();
  }

  Future<void> _initializeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  Future<void> _loadFeaturedGuitars() async {
    try {
      final response = await _apiService.getFeaturedGuitars();
      if (response.statusCode == 200) {
        final guitars = response.data['data'] as List;
        setState(() {
          featuredProducts = guitars.map((guitar) => {
            "name": guitar['name'],
            "price": "\$${guitar['price'].toStringAsFixed(2)}",
            "image": guitar['images']?.isNotEmpty == true 
                ? guitar['images'][0] 
                : "assets/image/bass_guitar.jpg", // fallback image
            "id": guitar['_id'],
            "brand": guitar['brand'],
            "rating": guitar['rating']?.toDouble() ?? 0.0,
          }).toList();
          isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        errorMessage = 'Failed to load guitars';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Network error';
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _apiService.clearAuthToken();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 206, 220, 3)),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 154, 4, 107),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/image/guitarhaus.png',
              height: 38,
            ),
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          const SizedBox(height: 10),
          const Text(
            "Welcome to GuitarHaus!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/image/banner.jpg',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Discover your favorite Guitars items",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search),
                hintText: 'Search guitars...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Categories", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to category page
                    // You can implement category filtering here
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: cat['color'] ?? Colors.blue,
                        radius: 24,
                        child: Icon(cat['icon'], color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['label'],
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Featured Products", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else if (featuredProducts.isEmpty)
            const Center(
              child: Text(
                "No featured guitars available",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: featuredProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final product = featuredProducts[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to guitar details page
                      // You can implement this later
                    },
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            child: Image.asset(
                              product['image'],
                              height: 120,
                              width: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 120,
                                width: 150,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 50, color: Colors.grey),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product['brand'],
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      product['price'],
                                      style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: Colors.amber),
                                        Text(
                                          product['rating'].toString(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color.fromARGB(255, 201, 3, 198),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          switch (index) {
            case 0:
              // Stay on Dashboard
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
