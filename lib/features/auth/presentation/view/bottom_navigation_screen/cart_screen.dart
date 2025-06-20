import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102840),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102840),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Icon(Icons.shopping_cart, color: Colors.greenAccent, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.remove_shopping_cart, color: Colors.greenAccent, size: 80),
            const SizedBox(height: 20),
            const Text(
              "The Cart is Empty",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "There is Nothing in the cart.",
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
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.explore, color: Colors.black),
              label: const Text(
                "Browse Products",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: 'Ubuntu-Bold',
                ),
              ),
              
              onPressed: () {
               Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
          ],
        ),
      ),
    );
  }
}