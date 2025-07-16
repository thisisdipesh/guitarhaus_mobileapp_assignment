import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_service.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  String? emailError;
  String? passwordError;
  bool? isPasswordValid;
  bool isPasswordVisible = false;
  bool isLoading = false;

  void resetValidation() {
    setState(() {
      emailError = null;
      passwordError = null;
      isPasswordValid = null;
    });
  }

  Future<void> onLoginPressed() async {
    setState(() {
      isLoading = true;
      resetValidation();
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      // Basic validation
      if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
        setState(() {
          emailError = 'Enter a valid email';
          isLoading = false;
        });
        return;
      }

      if (password.isEmpty) {
        setState(() {
          passwordError = 'Password is required';
          isLoading = false;
        });
        return;
      }

      // Call API
      final response = await _apiService.login(email, password);

      if (response.statusCode == 200) {
        final data = response.data;

        // Store token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('userId', data['userId']);
        await prefs.setString('userRole', data['role']);

        // Set auth token for future API calls
        _apiService.setAuthToken(data['token']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Login successful"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              duration: const Duration(milliseconds: 800),
            ),
          );

          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } on DioException catch (e) {
      String errorMessage = 'Login failed';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Invalid email or password';
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }

      setState(() {
        passwordError = errorMessage;
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        passwordError = 'Network error. Please try again.';
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Network error. Please try again."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  OutlineInputBorder buildPasswordBorder() {
    if (isPasswordValid == null) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      );
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isPasswordValid! ? Colors.amberAccent : Colors.blueGrey,
      ),
    );
  }

  Icon? buildPasswordIcon() {
    if (isPasswordValid == null) return null;
    return Icon(
      isPasswordValid! ? Icons.check_circle_outline : Icons.error_outline,
      color: isPasswordValid! ? Colors.amberAccent : Colors.blueGrey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        resetValidation();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
              child: SingleChildScrollView(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: 370,
                      padding: const EdgeInsets.symmetric(
                        vertical: 36,
                        horizontal: 28,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.09),
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
                          // Logo with glow
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurpleAccent.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 32,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/image/guitarhaus.png',
                              height: 70,
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // App name
                          const Text(
                            "GuitarHaus",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Ubuntu',
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.deepPurple,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Login form
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email
                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFFB799FF),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Color(0xFFB799FF),
                                  ),
                                  errorText: emailError,
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.08),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              // Password
                              TextField(
                                controller: passwordController,
                                obscureText: !isPasswordVisible,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFFB799FF),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Color(0xFFB799FF),
                                  ),
                                  errorText: passwordError,
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.08),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              // Login button
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8F43EE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: isLoading ? null : onLoginPressed,
                                  child:
                                      isLoading
                                          ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                          : const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Signup link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/signup');
                                    },
                                    child: const Text(
                                      "Sign up",
                                      style: TextStyle(
                                        color: Color(0xFFB799FF),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
