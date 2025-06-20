import 'package:flutter/material.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/cart_screen.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/favorites_screen.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/profile_screen.dart';
import 'theme/theme.dart'; // ✅ Import the theme
import 'features/auth/presentation/view/login_screen.dart';
import 'features/auth/presentation/view/signup_screen.dart';
import 'features/auth/presentation/view/splash_screen.dart';
import 'features/auth/presentation/view/bottom_navigation_screen/dashboard_screen.dart';

void main() {
  runApp(const GuitarHaus());
}

class GuitarHaus extends StatelessWidget {
  const GuitarHaus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuitarHaus',
      debugShowCheckedModeBanner: false,
      theme: appTheme, // ✅ Use centralized theme
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) =>  DashboardScreen(),
        '/favorites': (context)=> FavoritesScreen(),
        '/profile': (context)=> ProfileScreen(),
        '/cart': (context) => CartScreen()
      },
    );
  }
}