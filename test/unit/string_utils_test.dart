import 'package:flutter_test/flutter_test.dart';

// String utility functions for testing
class StringUtils {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
  }

  static String removeExtraSpaces(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  static String formatPhoneNumber(String phone) {
    if (phone.length != 10) return phone;
    return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
  }

  static String generateSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  static bool isPalindrome(String text) {
    final cleanText = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return cleanText == cleanText.split('').reversed.join();
  }

  static int countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  static String reverse(String text) {
    return text.split('').reversed.join();
  }

  static bool containsOnlyLetters(String text) {
    return RegExp(r'^[a-zA-Z\s]*$').hasMatch(text);
  }

  static bool containsOnlyNumbers(String text) {
    return RegExp(r'^[0-9]*$').hasMatch(text);
  }

  static String extractNumbers(String text) {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String extractLetters(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }

  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) return email;

    final maskedUsername =
        username[0] +
        '*' * (username.length - 2) +
        username[username.length - 1];
    return '$maskedUsername@$domain';
  }

  static String maskPhone(String phone) {
    if (phone.length < 4) return phone;
    return phone.substring(0, 2) +
        '*' * (phone.length - 4) +
        phone.substring(phone.length - 2);
  }
}

void main() {
  group('StringUtils Unit Tests', () {
    group('Text Formatting Tests', () {
      test('should capitalize first letter', () {
        expect(StringUtils.capitalize('hello'), 'Hello');
        expect(StringUtils.capitalize('WORLD'), 'World');
        expect(StringUtils.capitalize('tEsT'), 'Test');
      });

      test('should handle empty string in capitalize', () {
        expect(StringUtils.capitalize(''), '');
      });

      test('should truncate long text', () {
        expect(StringUtils.truncate('Hello World', 5), 'Hello...');
        expect(StringUtils.truncate('Short', 10), 'Short');
        expect(StringUtils.truncate('', 5), '');
      });

      test('should remove extra spaces', () {
        expect(
          StringUtils.removeExtraSpaces('  hello   world  '),
          'hello world',
        );
        expect(
          StringUtils.removeExtraSpaces('no   extra   spaces'),
          'no extra spaces',
        );
        expect(StringUtils.removeExtraSpaces(''), '');
      });

      test('should format price correctly', () {
        expect(StringUtils.formatPrice(10.5), '\$10.50');
        expect(StringUtils.formatPrice(0), '\$0.00');
        expect(StringUtils.formatPrice(123.456), '\$123.46');
      });

      test('should format phone number', () {
        expect(StringUtils.formatPhoneNumber('1234567890'), '(123) 456-7890');
        expect(StringUtils.formatPhoneNumber('123'), '123');
        expect(StringUtils.formatPhoneNumber(''), '');
      });
    });

    group('Text Manipulation Tests', () {
      test('should generate slug from text', () {
        expect(StringUtils.generateSlug('Hello World!'), 'hello-world');
        expect(StringUtils.generateSlug('Test & Sample'), 'test-sample');
        expect(
          StringUtils.generateSlug('Multiple   Spaces'),
          'multiple-spaces',
        );
      });

      test('should detect palindrome', () {
        expect(StringUtils.isPalindrome('racecar'), true);
        expect(StringUtils.isPalindrome('A man a plan a canal Panama'), true);
        expect(StringUtils.isPalindrome('hello'), false);
        expect(StringUtils.isPalindrome(''), true);
      });

      test('should count words correctly', () {
        expect(StringUtils.countWords('Hello world'), 2);
        expect(StringUtils.countWords('Single'), 1);
        expect(StringUtils.countWords(''), 0);
        expect(StringUtils.countWords('   '), 0);
        expect(StringUtils.countWords('Multiple   spaces'), 2);
      });

      test('should reverse string', () {
        expect(StringUtils.reverse('hello'), 'olleh');
        expect(StringUtils.reverse(''), '');
        expect(StringUtils.reverse('12345'), '54321');
      });
    });

    group('Text Validation Tests', () {
      test('should validate letters only', () {
        expect(StringUtils.containsOnlyLetters('Hello World'), true);
        expect(StringUtils.containsOnlyLetters('Hello123'), false);
        expect(StringUtils.containsOnlyLetters(''), true);
        expect(StringUtils.containsOnlyLetters('Hello!'), false);
      });

      test('should validate numbers only', () {
        expect(StringUtils.containsOnlyNumbers('12345'), true);
        expect(StringUtils.containsOnlyNumbers('123abc'), false);
        expect(StringUtils.containsOnlyNumbers(''), true);
        expect(StringUtils.containsOnlyNumbers('12.34'), false);
      });

      test('should extract numbers from text', () {
        expect(StringUtils.extractNumbers('abc123def456'), '123456');
        expect(StringUtils.extractNumbers('no numbers'), '');
        expect(StringUtils.extractNumbers(''), '');
        expect(StringUtils.extractNumbers('123'), '123');
      });

      test('should extract letters from text', () {
        expect(StringUtils.extractLetters('abc123def456'), 'abcdef');
        expect(StringUtils.extractLetters('123456'), '');
        expect(StringUtils.extractLetters(''), '');
        expect(StringUtils.extractLetters('abc'), 'abc');
      });

      test('should validate URL format', () {
        expect(StringUtils.isValidUrl('https://example.com'), true);
        expect(StringUtils.isValidUrl('http://test.org'), true);
        expect(StringUtils.isValidUrl('invalid-url'), false);
        expect(StringUtils.isValidUrl(''), false);
        // Test with valid URL that might be incorrectly flagged
        expect(StringUtils.isValidUrl('https://test.com'), true);
      });
    });

    group('Data Masking Tests', () {
      test('should mask email address', () {
        expect(StringUtils.maskEmail('test@example.com'), 't**t@example.com');
        expect(StringUtils.maskEmail('ab@example.com'), 'ab@example.com');
        expect(StringUtils.maskEmail('a@example.com'), 'a@example.com');
        expect(StringUtils.maskEmail('invalid-email'), 'invalid-email');
      });

      test('should mask phone number', () {
        expect(StringUtils.maskPhone('1234567890'), '12******90');
        expect(StringUtils.maskPhone('123456'), '12**56');
        expect(StringUtils.maskPhone('123'), '123');
        expect(StringUtils.maskPhone(''), '');
      });
    });

    group('Edge Cases Tests', () {
      test('should handle null-like empty strings', () {
        expect(StringUtils.capitalize(''), '');
        expect(StringUtils.truncate('', 5), '');
        expect(StringUtils.removeExtraSpaces(''), '');
        expect(StringUtils.countWords(''), 0);
        expect(StringUtils.reverse(''), '');
      });

      test('should handle single characters', () {
        expect(StringUtils.capitalize('a'), 'A');
        expect(StringUtils.truncate('a', 1), 'a');
        expect(StringUtils.countWords('a'), 1);
        expect(StringUtils.reverse('a'), 'a');
      });

      test('should handle special characters', () {
        expect(StringUtils.generateSlug('Test@#\$%^&*()'), 'test');
        expect(StringUtils.extractNumbers('abc@#\$%123'), '123');
        expect(StringUtils.extractLetters('123@#\$%abc'), 'abc');
      });

      test('should handle very long strings', () {
        final longString = 'a' * 1000;
        expect(StringUtils.truncate(longString, 10), 'aaaaaaaaaa...');
        expect(StringUtils.countWords(longString), 1);
      });
    });
  });
}
