import 'package:flutter/material.dart';
import 'login_screen.dart'; // Or change to 'home_screen.dart' if going to home directly
import 'dart:ui';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _rotationAnimation = Tween<double>(
      begin: -0.08,
      end: 0.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    // Simulate loading
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
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
          ),
          // Glassmorphism card
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 28,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated shimmer logo with rotation
                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [
                                    Color(0xFFB799FF),
                                    Color(0xFF8F43EE),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: Image.asset(
                                'assets/image/guitarhaus.png',
                                height: 90,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                      size: 80,
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // App name
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          'GuitarHaus',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Ubuntu',
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.deepPurple,
                                blurRadius: 12,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Elegant tagline
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          'Strum into the world of guitars!',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Ubuntu-Italic',
                            letterSpacing: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Loading spinner
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const CircularProgressIndicator(
                          color: Color(0xFFB799FF),
                          strokeWidth: 3.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
