import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAuthToken();
    _loadUserProfile();
  }

  Future<void> _initializeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId != null) {
        final response = await _apiService.getUserProfile(userId);
        if (response.statusCode == 200) {
          setState(() {
            userProfile = response.data['data'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'User ID not found';
          isLoading = false;
        });
      }
    } on DioException {
      setState(() {
        errorMessage = 'Failed to load profile';
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
      backgroundColor: const Color(0xFF673AB7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Icon(Icons.person, color: Colors.black54, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : errorMessage != null
                ? _buildErrorState()
                : _buildProfileContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 80),
        const SizedBox(height: 20),
        Text(
          errorMessage!,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'Ubuntu-Bold',
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loadUserProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Retry",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Ubuntu-Bold',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    if (userProfile == null) {
      return _buildErrorState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Picture
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: userProfile!['image'] != null
                ? NetworkImage(userProfile!['image'])
                : null,
            child: userProfile!['image'] == null
                ? const Icon(
                    Icons.person,
                    size: 45,
                    color: Colors.black,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 20),

        // Welcome Message
        Center(
          child: Text(
            'Welcome back, ${userProfile!['fname'] ?? 'User'}!',
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontFamily: 'Ubuntu-Bold',
            ),
          ),
        ),
        const SizedBox(height: 8),

        Center(
          child: Text(
            'Manage your profile details here.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
              fontFamily: 'Ubuntu-Italic',
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Profile Information
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildProfileItem('Name', '${userProfile!['fname'] ?? ''} ${userProfile!['lname'] ?? ''}'),
              _buildProfileItem('Email', userProfile!['email'] ?? ''),
              _buildProfileItem('Phone', userProfile!['phone']?.toString() ?? ''),
              _buildProfileItem('Role', userProfile!['role'] ?? 'customer'),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Action Buttons
        Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.edit, color: Colors.black),
            label: const Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
            onPressed: () {
              // Navigate to edit profile screen
              // You can implement this later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile feature coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.shopping_bag, color: Colors.white),
            label: const Text(
              "My Orders",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Ubuntu-Bold',
              ),
            ),
            onPressed: () {
              // Navigate to orders screen
              // You can implement this later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Orders feature coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}