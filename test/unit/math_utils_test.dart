import 'package:flutter_test/flutter_test.dart';
import 'dart:math' as math;

// Mathematical utility functions for testing
class MathUtils {
  static double roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = math.pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    return '${roundToDecimalPlaces(value * 100, decimalPlaces)}%';
  }

  static double calculatePercentage(double part, double total) {
    if (total == 0) return 0;
    return (part / total) * 100;
  }

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

  static double calculateTax(double amount, double taxRate) {
    return amount * (taxRate / 100);
  }

  static double calculateTotalWithTax(double amount, double taxRate) {
    return amount + calculateTax(amount, taxRate);
  }

  static double calculateAverage(List<double> numbers) {
    if (numbers.isEmpty) return 0;
    return numbers.reduce((a, b) => a + b) / numbers.length;
  }

  static double findMin(List<double> numbers) {
    if (numbers.isEmpty) return 0;
    return numbers.reduce(math.min);
  }

  static double findMax(List<double> numbers) {
    if (numbers.isEmpty) return 0;
    return numbers.reduce(math.max);
  }

  static double calculateMedian(List<double> numbers) {
    if (numbers.isEmpty) return 0;

    final sorted = List<double>.from(numbers)..sort();
    final length = sorted.length;

    if (length % 2 == 0) {
      return (sorted[length ~/ 2 - 1] + sorted[length ~/ 2]) / 2;
    } else {
      return sorted[length ~/ 2];
    }
  }

  static bool isPrime(int number) {
    if (number < 2) return false;
    if (number == 2) return true;
    if (number % 2 == 0) return false;

    for (int i = 3; i <= math.sqrt(number); i += 2) {
      if (number % i == 0) return false;
    }
    return true;
  }

  static int factorial(int n) {
    if (n < 0)
      throw ArgumentError('Factorial is not defined for negative numbers');
    if (n == 0 || n == 1) return 1;

    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  static int gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  static int lcm(int a, int b) {
    return (a * b) ~/ gcd(a, b);
  }

  static bool isEven(int number) {
    return number % 2 == 0;
  }

  static bool isOdd(int number) {
    return number % 2 != 0;
  }

  static int sumOfDigits(int number) {
    return number
        .toString()
        .split('')
        .map((digit) => int.parse(digit))
        .reduce((a, b) => a + b);
  }

  static bool isPalindrome(int number) {
    final str = number.toString();
    return str == str.split('').reversed.join();
  }

  static double calculateDistance(double x1, double y1, double x2, double y2) {
    return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
  }

  static double calculateAreaOfCircle(double radius) {
    return math.pi * radius * radius;
  }

  static double calculateCircumferenceOfCircle(double radius) {
    return 2 * math.pi * radius;
  }

  static double convertCelsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  static double convertFahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  static double convertKilometersToMiles(double kilometers) {
    return kilometers * 0.621371;
  }

  static double convertMilesToKilometers(double miles) {
    return miles * 1.60934;
  }
}

void main() {
  group('MathUtils Unit Tests', () {
    group('Rounding and Formatting Tests', () {
      test('should round to decimal places', () {
        expect(MathUtils.roundToDecimalPlaces(3.14159, 2), 3.14);
        expect(MathUtils.roundToDecimalPlaces(3.14159, 3), 3.142);
        expect(MathUtils.roundToDecimalPlaces(3.14159, 0), 3.0);
      });

      test('should format currency correctly', () {
        expect(MathUtils.formatCurrency(10.5), '\$10.50');
        expect(MathUtils.formatCurrency(0), '\$0.00');
        expect(MathUtils.formatCurrency(123.456), '\$123.46');
        expect(MathUtils.formatCurrency(10.5, symbol: '€'), '€10.50');
      });

      test('should format percentage correctly', () {
        expect(MathUtils.formatPercentage(0.25), '25.0%');
        expect(MathUtils.formatPercentage(0.123, decimalPlaces: 2), '12.3%');
        expect(MathUtils.formatPercentage(1.0), '100.0%');
      });
    });

    group('Percentage Calculation Tests', () {
      test('should calculate percentage correctly', () {
        expect(MathUtils.calculatePercentage(25, 100), 25.0);
        expect(MathUtils.calculatePercentage(50, 200), 25.0);
        expect(MathUtils.calculatePercentage(0, 100), 0.0);
      });

      test('should handle zero total in percentage calculation', () {
        expect(MathUtils.calculatePercentage(25, 0), 0.0);
      });
    });

    group('Price and Discount Tests', () {
      test('should calculate discount amount', () {
        expect(MathUtils.calculateDiscount(100, 20), 20.0);
        expect(MathUtils.calculateDiscount(50, 10), 5.0);
        expect(MathUtils.calculateDiscount(0, 20), 0.0);
      });

      test('should calculate final price after discount', () {
        expect(MathUtils.calculateFinalPrice(100, 20), 80.0);
        expect(MathUtils.calculateFinalPrice(50, 10), 45.0);
        expect(MathUtils.calculateFinalPrice(0, 20), 0.0);
      });

      test('should calculate tax amount', () {
        expect(MathUtils.calculateTax(100, 8.5), 8.5);
        expect(MathUtils.calculateTax(50, 10), 5.0);
        expect(MathUtils.calculateTax(0, 8.5), 0.0);
      });

      test('should calculate total with tax', () {
        expect(MathUtils.calculateTotalWithTax(100, 8.5), 108.5);
        expect(MathUtils.calculateTotalWithTax(50, 10), 55.0);
        expect(MathUtils.calculateTotalWithTax(0, 8.5), 0.0);
      });
    });

    group('Statistical Tests', () {
      test('should calculate average correctly', () {
        expect(MathUtils.calculateAverage([1, 2, 3, 4, 5]), 3.0);
        expect(MathUtils.calculateAverage([10, 20, 30]), 20.0);
        expect(MathUtils.calculateAverage([]), 0.0);
      });

      test('should find minimum value', () {
        expect(MathUtils.findMin([5, 2, 8, 1, 9]), 1.0);
        expect(MathUtils.findMin([10, 20, 30]), 10.0);
        expect(MathUtils.findMin([]), 0.0);
      });

      test('should find maximum value', () {
        expect(MathUtils.findMax([5, 2, 8, 1, 9]), 9.0);
        expect(MathUtils.findMax([10, 20, 30]), 30.0);
        expect(MathUtils.findMax([]), 0.0);
      });

      test('should calculate median correctly', () {
        expect(MathUtils.calculateMedian([1, 3, 5, 7, 9]), 5.0);
        expect(MathUtils.calculateMedian([1, 2, 3, 4]), 2.5);
        expect(MathUtils.calculateMedian([]), 0.0);
      });
    });

    group('Number Theory Tests', () {
      test('should identify prime numbers', () {
        expect(MathUtils.isPrime(2), true);
        expect(MathUtils.isPrime(3), true);
        expect(MathUtils.isPrime(4), false);
        expect(MathUtils.isPrime(17), true);
        expect(MathUtils.isPrime(1), false);
        expect(MathUtils.isPrime(0), false);
        expect(MathUtils.isPrime(-1), false);
      });

      test('should calculate factorial correctly', () {
        expect(MathUtils.factorial(0), 1);
        expect(MathUtils.factorial(1), 1);
        expect(MathUtils.factorial(5), 120);
        expect(MathUtils.factorial(3), 6);
      });

      test('should throw error for negative factorial', () {
        expect(() => MathUtils.factorial(-1), throwsArgumentError);
      });

      test('should calculate GCD correctly', () {
        expect(MathUtils.gcd(48, 18), 6);
        expect(MathUtils.gcd(12, 8), 4);
        expect(MathUtils.gcd(7, 13), 1);
      });

      test('should calculate LCM correctly', () {
        expect(MathUtils.lcm(12, 18), 36);
        expect(MathUtils.lcm(8, 12), 24);
        expect(MathUtils.lcm(7, 13), 91);
      });
    });

    group('Number Properties Tests', () {
      test('should identify even numbers', () {
        expect(MathUtils.isEven(2), true);
        expect(MathUtils.isEven(4), true);
        expect(MathUtils.isEven(0), true);
        expect(MathUtils.isEven(1), false);
        expect(MathUtils.isEven(3), false);
      });

      test('should identify odd numbers', () {
        expect(MathUtils.isOdd(1), true);
        expect(MathUtils.isOdd(3), true);
        expect(MathUtils.isOdd(2), false);
        expect(MathUtils.isOdd(4), false);
        expect(MathUtils.isOdd(0), false);
      });

      test('should calculate sum of digits', () {
        expect(MathUtils.sumOfDigits(123), 6);
        expect(MathUtils.sumOfDigits(456), 15);
        expect(MathUtils.sumOfDigits(0), 0);
        expect(MathUtils.sumOfDigits(999), 27);
      });

      test('should identify palindrome numbers', () {
        expect(MathUtils.isPalindrome(121), true);
        expect(MathUtils.isPalindrome(12321), true);
        expect(MathUtils.isPalindrome(123), false);
        expect(MathUtils.isPalindrome(0), true);
      });
    });

    group('Geometry Tests', () {
      test('should calculate distance between points', () {
        expect(MathUtils.calculateDistance(0, 0, 3, 4), 5.0);
        expect(MathUtils.calculateDistance(1, 1, 4, 5), 5.0);
        expect(MathUtils.calculateDistance(0, 0, 0, 0), 0.0);
      });

      test('should calculate area of circle', () {
        expect(MathUtils.calculateAreaOfCircle(1), math.pi);
        expect(MathUtils.calculateAreaOfCircle(2), 4 * math.pi);
        expect(MathUtils.calculateAreaOfCircle(0), 0.0);
      });

      test('should calculate circumference of circle', () {
        expect(MathUtils.calculateCircumferenceOfCircle(1), 2 * math.pi);
        expect(MathUtils.calculateCircumferenceOfCircle(2), 4 * math.pi);
        expect(MathUtils.calculateCircumferenceOfCircle(0), 0.0);
      });
    });

    group('Unit Conversion Tests', () {
      test('should convert Celsius to Fahrenheit', () {
        expect(MathUtils.convertCelsiusToFahrenheit(0), 32.0);
        expect(MathUtils.convertCelsiusToFahrenheit(100), 212.0);
        expect(MathUtils.convertCelsiusToFahrenheit(37), 98.6);
      });

      test('should convert Fahrenheit to Celsius', () {
        expect(MathUtils.convertFahrenheitToCelsius(32), 0.0);
        expect(MathUtils.convertFahrenheitToCelsius(212), 100.0);
        expect(MathUtils.convertFahrenheitToCelsius(98.6), 37.0);
      });

      test('should convert kilometers to miles', () {
        expect(MathUtils.convertKilometersToMiles(1), 0.621371);
        expect(MathUtils.convertKilometersToMiles(10), 6.21371);
        expect(MathUtils.convertKilometersToMiles(0), 0.0);
      });

      test('should convert miles to kilometers', () {
        expect(MathUtils.convertMilesToKilometers(1), 1.60934);
        expect(MathUtils.convertMilesToKilometers(10), 16.0934);
        expect(MathUtils.convertMilesToKilometers(0), 0.0);
      });
    });
  });
}
