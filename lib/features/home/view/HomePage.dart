import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:guitarhaus_mobileapp_assignment/core/network/api_service.dart';
import '../../auth/presentation/view/featured_guitars_screen.dart';
import 'dart:ui';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Remove guitars state, _fetchGuitars, and any guitar list UI from HomePage
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // _fetchGuitars(); // This line is removed
  }

  // Future<void> _fetchGuitars() async { // This function is removed
  //   setState(() {
  //     isGuitarsLoading = true;
  //     guitarsError = null;
  //   });
  //   try {
  //     final response = await _apiService.getGuitars(limit: 1000);
  //     print('HOMEPAGE GUITARS API RESPONSE: ' + response.data.toString());
  //     if (response.statusCode == 200) {
  //       final items = response.data['data'] as List;
  //       setState(() {
  //         guitars =
  //             items
  //                 .map(
  //                   (g) => {
  //                     'id': g['_id'],
  //                     'name': g['name'],
  //                     'brand': g['brand'],
  //                     'price': g['price'].toString(),
  //                     'category': g['category'],
  //                   },
  //                 )
  //                 .toList();
  //         isGuitarsLoading = false;
  //       });
  //     } else {
  //       setState(() {
  //         guitarsError = 'Failed to load guitars: \\${response.statusMessage}';
  //         isGuitarsLoading = false;
  //       });
  //     }
  //   } on DioException catch (e) {
  //     print('DioException: ' + e.toString());
  //     setState(() {
  //       guitarsError = 'Network error: ' + (e.message ?? e.toString());
  //       isGuitarsLoading = false;
  //     });
  //   } catch (e, stack) {
  //     print('Unexpected error in _fetchGuitars: ' + e.toString());
  //     print(stack);
  //     setState(() {
  //       guitarsError = 'Unexpected error: ' + e.toString();
  //       isGuitarsLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF18122B), Color(0xFF393053)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner (compact, centered)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/image/guitarhaus.png',
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'GuitarHaus',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Ubuntu',
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Discover your favorite Guitars',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Find the best guitars for every style and budget.',
                    style: TextStyle(fontSize: 14, color: Colors.white38),
                  ),
                  const SizedBox(height: 18),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Colors.deepPurple),
                        hintText: 'Search guitars...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB799FF),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 64,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildGuitarPickChip(
                    'Electric Guitar',
                    Icons.electric_bolt,
                    Color(0xFFB799FF),
                  ),
                  _buildGuitarPickChip(
                    'Acoustic Guitar',
                    Icons.music_note,
                    Color(0xFF8F43EE),
                  ),
                  _buildGuitarPickChip(
                    'Bass Guitar',
                    Icons.library_music,
                    Color(0xFF00C9A7),
                  ),
                  _buildGuitarPickChip(
                    'Classical Guitar',
                    Icons.queue_music,
                    Color(0xFFFFB300),
                  ),
                  _buildGuitarPickChip(
                    'Ukulele',
                    Icons.music_video,
                    Color(0xFFFD5E53),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Featured Guitars Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Guitars',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB799FF),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeaturedGuitarsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFFB799FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Featured Guitars Preview
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF232946), Color(0xFF2D1E2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFB799FF),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Premium Selection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Ubuntu-Bold',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Handpicked guitars by our experts',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const FeaturedGuitarsScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB799FF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Explore Featured',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Featured Products
            // isGuitarsLoading // This line is removed
            //     ? const Center( // This line is removed
            //       child: CircularProgressIndicator(color: Color(0xFFB799FF)), // This line is removed
            //     ) // This line is removed
            //     : guitarsError != null // This line is removed
            //     ? Center( // This line is removed
            //       child: Text( // This line is removed
            //         guitarsError!, // This line is removed
            //         style: const TextStyle(color: Colors.white70), // This line is removed
            //       ), // This line is removed
            //     ) // This line is removed
            //     : ListView.separated( // This line is removed
            //       shrinkWrap: true, // This line is removed
            //       physics: const NeverScrollableScrollPhysics(), // This line is removed
            //       itemCount: guitars.length, // This line is removed
            //       separatorBuilder: // This line is removed
            //           (context, index) => const SizedBox(height: 18), // This line is removed
            //       itemBuilder: (context, index) { // This line is removed
            //         final guitar = guitars[index]; // This line is removed
            //         return Container( // This line is removed
            //           margin: const EdgeInsets.symmetric(horizontal: 16), // This line is removed
            //           decoration: BoxDecoration( // This line is removed
            //             borderRadius: BorderRadius.circular(20), // This line is removed
            //             color: const Color(0xFF232946), // This line is removed
            //             boxShadow: [ // This line is removed
            //               BoxShadow( // This line is removed
            //                 color: Colors.black26, // This line is removed
            //                 blurRadius: 12, // This line is removed
            //                 offset: Offset(0, 6), // This line is removed
            //               ), // This line is removed
            //             ], // This line is removed
            //           ), // This line is removed
            //           child: ListTile( // This line is removed
            //             leading: ClipRRect( // This line is removed
            //               borderRadius: BorderRadius.circular(12), // This line is removed
            //               child: Image.network( // This line is removed
            //                 'http://10.0.2.2:3000/api/v1/guitars/${guitar['id']}/image', // This line is removed
            //                 width: 54, // This line is removed
            //                 height: 54, // This line is removed
            //                 fit: BoxFit.cover, // This line is removed
            //                 errorBuilder: // This line is removed
            //                     (context, error, stackTrace) => Container( // This line is removed
            //                       width: 54, // This line is removed
            //                       height: 54, // This line is removed
            //                       color: Colors.grey[300], // This line is removed
            //                       child: const Icon( // This line is removed
            //                         Icons.image, // This line is removed
            //                         size: 32, // This line is removed
            //                         color: Colors.grey, // This line is removed
            //                       ), // This line is removed
            //                     ), // This line is removed
            //               ), // This line is removed
            //             ), // This line is removed
            //             title: Text( // This line is removed
            //               guitar['name'], // This line is removed
            //               style: const TextStyle( // This line is removed
            //                 fontWeight: FontWeight.bold, // This line is removed
            //                 fontSize: 16, // This line is removed
            //                 color: Colors.white, // This line is removed
            //               ), // This line is removed
            //             ), // This line is removed
            //             subtitle: Text( // This line is removed
            //               guitar['brand'] ?? '', // This line is removed
            //               style: const TextStyle( // This line is removed
            //                 color: Colors.white70, // This line is removed
            //                 fontSize: 13, // This line is removed
            //               ), // This line is removed
            //             ), // This line is removed
            //             trailing: Text( // This line is removed
            //               '\u20B9${guitar['price']}', // This line is removed
            //               style: const TextStyle( // This line is removed
            //                 color: Color(0xFFB799FF), // This line is removed
            //                 fontWeight: FontWeight.bold, // This line is removed
            //                 fontSize: 15, // This line is removed
            //               ), // This line is removed
            //             ), // This line is removed
            //           ), // This line is removed
            //         ); // This line is removed
            //       }, // This line is removed
            //     ), // This line is removed
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGuitarPickChip(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(22),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: ShapeDecoration(
            color: color,
            shape: const StadiumBorder(),
            shadows: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF232946),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(
              product['image']!,
              height: 50,
              width: 140,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (product['brand'] != null)
                  Text(
                    product['brand']!,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      product['price'] ?? '',
                      style: const TextStyle(
                        color: Color(0xFFB799FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 24,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F43EE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 1,
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Buy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
