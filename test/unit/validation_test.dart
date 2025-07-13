import 'package:flutter_test/flutter_test.dart';

class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone);
  }

  static bool isValidName(String name) {
    return name.trim().length >= 2;
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

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(password)) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (!isValidName(name)) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhone(phone)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }
}

void main() {
  group('ValidationUtils Unit Tests', () {
    group('Email Validation Tests', () {
      test('should validate correct email addresses', () {
        expect(ValidationUtils.isValidEmail('test@example.com'), true);
        expect(ValidationUtils.isValidEmail('user.name@domain.co.uk'), true);
        expect(ValidationUtils.isValidEmail('test123@test.org'), true);
      });

      test('should reject invalid email addresses', () {
        expect(ValidationUtils.isValidEmail('invalid-email'), false);
        expect(ValidationUtils.isValidEmail('test@'), false);
        expect(ValidationUtils.isValidEmail('@example.com'), false);
        expect(ValidationUtils.isValidEmail(''), false);
      });

      test('should return error for empty email', () {
        expect(ValidationUtils.validateEmail(''), 'Email is required');
        expect(ValidationUtils.validateEmail(null), 'Email is required');
      });

      test('should return error for invalid email format', () {
        expect(ValidationUtils.validateEmail('invalid'), 'Please enter a valid email');
        expect(ValidationUtils.validateEmail('test@'), 'Please enter a valid email');
      });

      test('should return null for valid email', () {
        expect(ValidationUtils.validateEmail('test@example.com'), null);
        expect(ValidationUtils.validateEmail('user.name@domain.co.uk'), null);
      });
    });

    group('Password Validation Tests', () {
      test('should validate correct passwords', () {
        expect(ValidationUtils.isValidPassword('password123'), true);
        expect(ValidationUtils.isValidPassword('123456'), true);
        expect(ValidationUtils.isValidPassword('abcdef'), true);
      });

      test('should reject short passwords', () {
        expect(ValidationUtils.isValidPassword('12345'), false);
        expect(ValidationUtils.isValidPassword('abc'), false);
        expect(ValidationUtils.isValidPassword(''), false);
      });

      test('should return error for empty password', () {
        expect(ValidationUtils.validatePassword(''), 'Password is required');
        expect(ValidationUtils.validatePassword(null), 'Password is required');
      });

      test('should return error for short password', () {
        expect(ValidationUtils.validatePassword('12345'), 'Password must be at least 6 characters');
      });

      test('should return null for valid password', () {
        expect(ValidationUtils.validatePassword('password123'), null);
        expect(ValidationUtils.validatePassword('123456'), null);
      });
    });

    group('Confirm Password Validation Tests', () {
      test('should return error for empty confirm password', () {
        expect(ValidationUtils.validateConfirmPassword('password123', ''), 'Please confirm your password');
        expect(ValidationUtils.validateConfirmPassword('password123', null), 'Please confirm your password');
      });

      test('should return error for mismatched passwords', () {
        expect(ValidationUtils.validateConfirmPassword('password123', 'password456'), 'Passwords do not match');
        expect(ValidationUtils.validateConfirmPassword('123456', '654321'), 'Passwords do not match');
      });

      test('should return null for matching passwords', () {
        expect(ValidationUtils.validateConfirmPassword('password123', 'password123'), null);
        expect(ValidationUtils.validateConfirmPassword('123456', '123456'), null);
      });
    });

    group('Name Validation Tests', () {
      test('should validate correct names', () {
        expect(ValidationUtils.isValidName('John'), true);
        expect(ValidationUtils.isValidName('Mary Jane'), true);
        expect(ValidationUtils.isValidName('A'), false);
        expect(ValidationUtils.isValidName(''), false);
      });

      test('should return error for empty name', () {
        expect(ValidationUtils.validateName(''), 'Name is required');
        expect(ValidationUtils.validateName(null), 'Name is required');
      });

      test('should return error for short name', () {
        expect(ValidationUtils.validateName('A'), 'Name must be at least 2 characters');
      });

      test('should return null for valid name', () {
        expect(ValidationUtils.validateName('John'), null);
        expect(ValidationUtils.validateName('Mary Jane'), null);
      });
    });

    group('Phone Validation Tests', () {
      test('should validate correct phone numbers', () {
        expect(ValidationUtils.isValidPhone('1234567890'), true);
        expect(ValidationUtils.isValidPhone('9876543210'), true);
      });

      test('should reject invalid phone numbers', () {
        expect(ValidationUtils.isValidPhone('123456789'), false); // too short
        expect(ValidationUtils.isValidPhone('12345678901'), false); // too long
        expect(ValidationUtils.isValidPhone('123456789a'), false); // contains letter
        expect(ValidationUtils.isValidPhone(''), false);
      });

      test('should return error for empty phone', () {
        expect(ValidationUtils.validatePhone(''), 'Phone number is required');
        expect(ValidationUtils.validatePhone(null), 'Phone number is required');
      });

      test('should return error for invalid phone format', () {
        expect(ValidationUtils.validatePhone('123456789'), 'Please enter a valid 10-digit phone number');
        expect(ValidationUtils.validatePhone('12345678901'), 'Please enter a valid 10-digit phone number');
        expect(ValidationUtils.validatePhone('123456789a'), 'Please enter a valid 10-digit phone number');
      });

      test('should return null for valid phone', () {
        expect(ValidationUtils.validatePhone('1234567890'), null);
        expect(ValidationUtils.validatePhone('9876543210'), null);
      });
    });
  });
} 