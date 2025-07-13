import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_service.dart';

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        backgroundColor: const Color(0xFFFF5722),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Column(
                children: [
                  Image.asset(
                    'assets/image/guitarhaus.png',
                    height: 80,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "GuitarHaus",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade300, width: 1.2),
                  ),
                  child: ListView(
                    children: [
                      TextField(
                        controller: emailController,
                        onTap: resetValidation,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(fontSize: 16),
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorText: emailError,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(fontSize: 16),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (buildPasswordIcon() != null) buildPasswordIcon()!,
                              IconButton(
                                icon: Icon(
                                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                            ],
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: buildPasswordBorder(),
                          errorText: passwordError,
                        ),
                      ),

                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            resetValidation();
                          },
                          child: const Text('Forgot password?', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: isLoading ? null : onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A1B2E),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("or", style: TextStyle(fontSize: 14)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: Image.asset('assets/image/google_logo.jpeg', height: 22),
                        label: const Text("Continue with Google", style: TextStyle(fontSize: 16)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              resetValidation();
                              Navigator.pushReplacementNamed(context, '/signup');
                            },
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A1B2E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}