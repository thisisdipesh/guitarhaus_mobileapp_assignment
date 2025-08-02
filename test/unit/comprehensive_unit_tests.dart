import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

// Utility classes for testing
class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}

class MathUtils {
  static double calculateDiscount(
    double originalPrice,
    double discountPercentage,
  ) {
    return originalPrice * (discountPercentage / 100);
  }

  static double calculateFinalPrice(
    double originalPrice,
    double discountPercentage,
  ) {
    return originalPrice - calculateDiscount(originalPrice, discountPercentage);
  }

  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;
}

class CartUtils {
  static List<CartItem> _items = [];

  static void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((element) => element.id == item.id);
    if (existingIndex != -1) {
      _items[existingIndex] = CartItem(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: _items[existingIndex].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
  }

  static double getTotalPrice() {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  static void clearCart() {
    _items.clear();
  }
}

class StringUtils {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatPhoneNumber(String phone) {
    if (phone.length != 10) return phone;
    return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
  }
}

class DateUtils {
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

void main() {
  group('Comprehensive Unit Tests - 10 Tests', () {
    // Test 1: Email Validation
    test('1. Email validation should work correctly', () {
      expect(ValidationUtils.validateEmail(''), 'Email is required');
      expect(
        ValidationUtils.validateEmail('invalid'),
        'Please enter a valid email',
      );
      expect(ValidationUtils.validateEmail('test@example.com'), null);
      expect(ValidationUtils.validateEmail('user.name@domain.co.uk'), null);
    });

    // Test 2: Password Validation
    test('2. Password validation should enforce minimum length', () {
      expect(ValidationUtils.isValidPassword('12345'), false);
      expect(ValidationUtils.isValidPassword('123456'), true);
      expect(ValidationUtils.isValidPassword('password123'), true);
    });

    // Test 3: Price Calculations
    test('3. Discount and final price calculations should be accurate', () {
      expect(MathUtils.calculateDiscount(100, 20), 20.0);
      expect(MathUtils.calculateFinalPrice(100, 20), 80.0);
      expect(MathUtils.calculateDiscount(50, 10), 5.0);
      expect(MathUtils.calculateFinalPrice(50, 10), 45.0);
    });

    // Test 4: Currency Formatting
    test('4. Currency formatting should display correctly', () {
      expect(MathUtils.formatCurrency(10.5), '\$10.50');
      expect(MathUtils.formatCurrency(0), '\$0.00');
      expect(MathUtils.formatCurrency(123.456), '\$123.46');
      expect(MathUtils.formatCurrency(10.5, symbol: '€'), '€10.50');
    });

    // Test 5: Cart Operations
    test('5. Cart should handle item addition and total calculation', () {
      CartUtils.clearCart();

      final item1 = CartItem(
        id: '1',
        name: 'Guitar',
        price: 299.99,
        quantity: 2,
      );
      final item2 = CartItem(
        id: '2',
        name: 'Strings',
        price: 19.99,
        quantity: 1,
      );

      CartUtils.addItem(item1);
      CartUtils.addItem(item2);

      final expectedTotal = (299.99 * 2) + (19.99 * 1);
      expect(CartUtils.getTotalPrice(), expectedTotal);
    });

    // Test 6: String Manipulation
    test('6. String utilities should format text correctly', () {
      expect(StringUtils.capitalize('hello'), 'Hello');
      expect(StringUtils.capitalize('WORLD'), 'World');
      expect(StringUtils.capitalize(''), '');
      expect(StringUtils.formatPhoneNumber('1234567890'), '(123) 456-7890');
      expect(StringUtils.formatPhoneNumber('123'), '123');
    });

    // Test 7: Date Formatting
    test('7. Date utilities should format dates correctly', () {
      final testDate = DateTime(2023, 12, 25);
      expect(DateUtils.formatDate(testDate), '25/12/2023');

      final today = DateTime.now();
      expect(DateUtils.isToday(today), true);

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateUtils.isToday(yesterday), false);
    });

    // Test 8: Cart Item Duplication
    test('8. Cart should handle duplicate items by updating quantity', () {
      CartUtils.clearCart();

      final item1 = CartItem(
        id: '1',
        name: 'Guitar',
        price: 299.99,
        quantity: 1,
      );
      final item2 = CartItem(
        id: '1',
        name: 'Guitar',
        price: 299.99,
        quantity: 2,
      );

      CartUtils.addItem(item1);
      CartUtils.addItem(item2);

      // Should have only one item with quantity 3
      expect(CartUtils.getTotalPrice(), 299.99 * 3);
    });

    // Test 9: Edge Cases
    test('9. Edge cases should be handled properly', () {
      // Zero values
      expect(MathUtils.calculateDiscount(0, 20), 0.0);
      expect(MathUtils.calculateFinalPrice(0, 20), 0.0);

      // Empty strings
      expect(StringUtils.capitalize(''), '');
      expect(ValidationUtils.validateEmail(''), 'Email is required');

      // Invalid phone numbers
      expect(StringUtils.formatPhoneNumber(''), '');
      expect(StringUtils.formatPhoneNumber('123'), '123');
    });

    // Test 10: Integration Test
    test('10. Complete e-commerce flow should work correctly', () {
      // Simulate a complete purchase flow
      CartUtils.clearCart();

      // Add items to cart
      final guitar = CartItem(
        id: '1',
        name: 'Electric Guitar',
        price: 599.99,
        quantity: 1,
      );
      final strings = CartItem(
        id: '2',
        name: 'Guitar Strings',
        price: 24.99,
        quantity: 2,
      );

      CartUtils.addItem(guitar);
      CartUtils.addItem(strings);

      // Calculate totals
      final subtotal = CartUtils.getTotalPrice();
      final discount = MathUtils.calculateDiscount(
        subtotal,
        10,
      ); // 10% discount
      final finalPrice = MathUtils.calculateFinalPrice(subtotal, 10);

      // Verify calculations
      expect(subtotal, (599.99 * 1) + (24.99 * 2));
      expect(discount, subtotal * 0.1);
      expect(finalPrice, subtotal - discount);

      // Format final price
      final formattedPrice = MathUtils.formatCurrency(finalPrice);
      expect(formattedPrice, '\$${finalPrice.toStringAsFixed(2)}');
    });
  });
}
