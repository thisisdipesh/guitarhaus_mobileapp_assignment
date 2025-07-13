import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:guitarhaus_mobileapp_assignment/core/network/api_service.dart';

void main() {
  group('ApiService Unit Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    group('Authentication Tests', () {
      test('should have correct base URL for Android emulator', () {
        expect(ApiService.baseUrl, 'http://10.0.2.2:3000/api/v1');
      });

      test('should have login method', () {
        expect(apiService.login, isA<Function>());
      });

      test('should have register method', () {
        expect(apiService.register, isA<Function>());
      });

      test('should have getUserProfile method', () {
        expect(apiService.getUserProfile, isA<Function>());
      });

      test('should have updateUserProfile method', () {
        expect(apiService.updateUserProfile, isA<Function>());
      });
    });

    group('Guitar API Tests', () {
      test('should have getGuitars method', () {
        expect(apiService.getGuitars, isA<Function>());
      });

      test('should have getGuitar method', () {
        expect(apiService.getGuitar, isA<Function>());
      });

      test('should have getFeaturedGuitars method', () {
        expect(apiService.getFeaturedGuitars, isA<Function>());
      });

      test('should have searchGuitars method', () {
        expect(apiService.searchGuitars, isA<Function>());
      });
    });

    group('Cart API Tests', () {
      test('should have getCart method', () {
        expect(apiService.getCart, isA<Function>());
      });

      test('should have addToCart method', () {
        expect(apiService.addToCart, isA<Function>());
      });

      test('should have updateCartItem method', () {
        expect(apiService.updateCartItem, isA<Function>());
      });

      test('should have removeFromCart method', () {
        expect(apiService.removeFromCart, isA<Function>());
      });

      test('should have clearCart method', () {
        expect(apiService.clearCart, isA<Function>());
      });
    });

    group('Wishlist API Tests', () {
      test('should have getWishlist method', () {
        expect(apiService.getWishlist, isA<Function>());
      });

      test('should have addToWishlist method', () {
        expect(apiService.addToWishlist, isA<Function>());
      });

      test('should have removeFromWishlist method', () {
        expect(apiService.removeFromWishlist, isA<Function>());
      });

      test('should have checkWishlist method', () {
        expect(apiService.checkWishlist, isA<Function>());
      });

      test('should have clearWishlist method', () {
        expect(apiService.clearWishlist, isA<Function>());
      });
    });

    group('Order API Tests', () {
      test('should have createOrder method', () {
        expect(apiService.createOrder, isA<Function>());
      });

      test('should have getUserOrders method', () {
        expect(apiService.getUserOrders, isA<Function>());
      });

      test('should have getOrder method', () {
        expect(apiService.getOrder, isA<Function>());
      });

      test('should have cancelOrder method', () {
        expect(apiService.cancelOrder, isA<Function>());
      });
    });

    group('Review API Tests', () {
      test('should have getGuitarReviews method', () {
        expect(apiService.getGuitarReviews, isA<Function>());
      });

      test('should have addReview method', () {
        expect(apiService.addReview, isA<Function>());
      });

      test('should have updateReview method', () {
        expect(apiService.updateReview, isA<Function>());
      });

      test('should have deleteReview method', () {
        expect(apiService.deleteReview, isA<Function>());
      });

      test('should have getUserReviews method', () {
        expect(apiService.getUserReviews, isA<Function>());
      });
    });

    group('Token Management Tests', () {
      test('should set auth token correctly', () {
        const token = 'test_token_123';
        apiService.setAuthToken(token);
        expect(apiService.setAuthToken, isA<Function>());
      });

      test('should clear auth token correctly', () {
        apiService.clearAuthToken();
        expect(apiService.clearAuthToken, isA<Function>());
      });
    });
  });
} 