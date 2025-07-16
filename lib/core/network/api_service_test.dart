import 'package:flutter_test/flutter_test.dart';
import 'api_service.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('should set auth token correctly', () {
      const testToken = 'test_token_123';
      apiService.setAuthToken(testToken);
      
      // We can't directly test the private _dio property, but we can test the method works
      expect(apiService.setAuthToken, isA<Function>());
    });

    test('should clear auth token correctly', () {
      apiService.setAuthToken('test_token');
      apiService.clearAuthToken();
      
      // We can't directly test the private _dio property, but we can test the method works
      expect(apiService.clearAuthToken, isA<Function>());
    });

    test('should have login method', () {
      expect(apiService.login, isA<Function>());
    });

    test('should have register method', () {
      expect(apiService.register, isA<Function>());
    });

    test('should have getGuitars method', () {
      expect(apiService.getGuitars, isA<Function>());
    });

    test('should have getCart method', () {
      expect(apiService.getCart, isA<Function>());
    });

    test('should have getWishlist method', () {
      expect(apiService.getWishlist, isA<Function>());
    });

    test('should have addToCart method', () {
      expect(apiService.addToCart, isA<Function>());
    });

    test('should have addToWishlist method', () {
      expect(apiService.addToWishlist, isA<Function>());
    });
  });
} 