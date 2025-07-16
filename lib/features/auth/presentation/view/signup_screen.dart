import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import 'dart:ui';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final ApiService _apiService = ApiService();

  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  void resetValidation() {
    setState(() {
      nameError = null;
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;
    });
  }

  Future<void> onSignupPressed() async {
    setState(() {
      isLoading = true;
      resetValidation();
    });

    try {
      String name = nameController.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text;
      String confirmPassword = confirmPasswordController.text;

      // Validation
      if (name.isEmpty) {
        setState(() {
          nameError = "Name is required";
          isLoading = false;
        });
        return;
      }

      if (email.isEmpty || !email.contains('@')) {
        setState(() {
          emailError = "Valid email required";
          isLoading = false;
        });
        return;
      }

      if (password.length < 6) {
        setState(() {
          passwordError = "Password must be at least 6 characters";
          isLoading = false;
        });
        return;
      }

      if (confirmPassword != password) {
        setState(() {
          confirmPasswordError = "Passwords do not match";
          isLoading = false;
        });
        return;
      }

      // Split name into first and last name
      List<String> nameParts = name.split(' ');
      String firstName = nameParts.first;
      String lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'User';

      // Call API
      final response = await _apiService.register({
        'fname': firstName,
        'lname': lastName,
        'email': email,
        'password': password,
        'phone': 1234567890, // You can add a phone field to the UI
      });

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Signup successful! Please login."),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              duration: const Duration(seconds: 2),
            ),
          );

          // Clear form
          nameController.clear();
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();

          // Navigate to login
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } on DioException catch (e) {
      String errorMessage = 'Signup failed';

      // Debug information
      print('DioException: ${e.message}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Connection error. Please check if the server is running.';
      }

      setState(() {
        emailError = errorMessage;
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
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('General Exception: $e');
      setState(() {
        emailError = 'Network error. Please try again.';
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
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
                          // Sign up form
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Full Name
                              TextField(
                                controller: nameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFFB799FF),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Color(0xFFB799FF),
                                  ),
                                  errorText: nameError,
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.08),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
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
                              const SizedBox(height: 16),
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
                              const SizedBox(height: 16),
                              // Confirm Password
                              TextField(
                                controller: confirmPasswordController,
                                obscureText: !isConfirmPasswordVisible,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFFB799FF),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFFB799FF),
                                  ),
                                  errorText: confirmPasswordError,
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.08),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isConfirmPasswordVisible =
                                            !isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Sign Up button
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
                                  onPressed: isLoading ? null : onSignupPressed,
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
                                            'Sign Up',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Login link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Already have an account? ",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    },
                                    child: const Text(
                                      "Log in",
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    IconData? suffixIcon,
    String? errorText,
    VoidCallback? onSuffixTap,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16),
        prefixIcon: Icon(icon),
        suffixIcon:
            suffixIcon != null
                ? IconButton(icon: Icon(suffixIcon), onPressed: onSuffixTap)
                : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorText: errorText,
      ),
    );
  }
}
