import 'package:flutter/material.dart';
import 'view/login_screen.dart'; 
import 'view/signup_screen.dart'; 
import 'view/splash_screen.dart'; 
void main() {
  runApp(GuitarHaus());
}

class GuitarHaus extends StatelessWidget {
  const GuitarHaus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuitarHaus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF0A1B2E),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A1B2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/', // Splash screen is the initial route
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
       
      },
    );
  }
}