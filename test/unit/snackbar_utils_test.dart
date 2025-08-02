import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock implementation for testing snackbar functionality
class SnackBarUtils {
  static String? lastMessage;
  static Color? lastColor;
  static Duration? lastDuration;

  static void showSnackBar({
    required String message,
    Color color = Colors.black87,
    Duration duration = const Duration(seconds: 2),
  }) {
    lastMessage = message;
    lastColor = color;
    lastDuration = duration;
  }

  static void reset() {
    lastMessage = null;
    lastColor = null;
    lastDuration = null;
  }

  static bool validateMessage(String message) {
    return message.isNotEmpty && message.length <= 100;
  }

  static bool validateColor(Color color) {
    return color != Colors.transparent;
  }

  static bool validateDuration(Duration duration) {
    return duration.inSeconds >= 1 && duration.inSeconds <= 10;
  }
}

void main() {
  group('SnackBarUtils Unit Tests', () {
    setUp(() {
      SnackBarUtils.reset();
    });

    group('SnackBar Display Tests', () {
      test('should display message with default settings', () {
        const message = 'Test message';
        SnackBarUtils.showSnackBar(message: message);

        expect(SnackBarUtils.lastMessage, message);
        expect(SnackBarUtils.lastColor, Colors.black87);
        expect(SnackBarUtils.lastDuration, const Duration(seconds: 2));
      });

      test('should display message with custom color', () {
        const message = 'Success message';
        const color = Colors.green;
        SnackBarUtils.showSnackBar(message: message, color: color);

        expect(SnackBarUtils.lastMessage, message);
        expect(SnackBarUtils.lastColor, color);
      });

      test('should display message with custom duration', () {
        const message = 'Long message';
        const duration = Duration(seconds: 5);
        SnackBarUtils.showSnackBar(message: message, duration: duration);

        expect(SnackBarUtils.lastMessage, message);
        expect(SnackBarUtils.lastDuration, duration);
      });

      test('should display message with all custom settings', () {
        const message = 'Custom message';
        const color = Colors.red;
        const duration = Duration(seconds: 3);

        SnackBarUtils.showSnackBar(
          message: message,
          color: color,
          duration: duration,
        );

        expect(SnackBarUtils.lastMessage, message);
        expect(SnackBarUtils.lastColor, color);
        expect(SnackBarUtils.lastDuration, duration);
      });
    });

    group('Message Validation Tests', () {
      test('should validate empty message', () {
        expect(SnackBarUtils.validateMessage(''), false);
      });

      test('should validate short message', () {
        expect(SnackBarUtils.validateMessage('Hi'), true);
      });

      test('should validate normal message', () {
        expect(SnackBarUtils.validateMessage('This is a test message'), true);
      });

      test('should validate long message', () {
        const longMessage =
            'This is a very long message that should still be valid for testing purposes';
        expect(SnackBarUtils.validateMessage(longMessage), true);
      });

      test('should reject very long message', () {
        const veryLongMessage =
            'This is a very long message that exceeds the maximum allowed length of 100 characters and should be rejected by the validation function';
        expect(SnackBarUtils.validateMessage(veryLongMessage), false);
      });
    });

    group('Color Validation Tests', () {
      test('should validate valid colors', () {
        expect(SnackBarUtils.validateColor(Colors.red), true);
        expect(SnackBarUtils.validateColor(Colors.green), true);
        expect(SnackBarUtils.validateColor(Colors.blue), true);
        expect(SnackBarUtils.validateColor(Colors.black87), true);
      });

      test('should reject transparent color', () {
        expect(SnackBarUtils.validateColor(Colors.transparent), false);
      });
    });

    group('Duration Validation Tests', () {
      test('should validate valid durations', () {
        expect(
          SnackBarUtils.validateDuration(const Duration(seconds: 1)),
          true,
        );
        expect(
          SnackBarUtils.validateDuration(const Duration(seconds: 5)),
          true,
        );
        expect(
          SnackBarUtils.validateDuration(const Duration(seconds: 10)),
          true,
        );
      });

      test('should reject too short duration', () {
        expect(
          SnackBarUtils.validateDuration(const Duration(seconds: 0)),
          false,
        );
      });

      test('should reject too long duration', () {
        expect(
          SnackBarUtils.validateDuration(const Duration(seconds: 11)),
          false,
        );
      });
    });

    group('Utility Function Tests', () {
      test('should reset all values', () {
        SnackBarUtils.showSnackBar(message: 'Test');
        SnackBarUtils.reset();

        expect(SnackBarUtils.lastMessage, null);
        expect(SnackBarUtils.lastColor, null);
        expect(SnackBarUtils.lastDuration, null);
      });

      test('should handle multiple calls', () {
        SnackBarUtils.showSnackBar(message: 'First message');
        SnackBarUtils.showSnackBar(
          message: 'Second message',
          color: Colors.blue,
        );

        expect(SnackBarUtils.lastMessage, 'Second message');
        expect(SnackBarUtils.lastColor, Colors.blue);
      });
    });
  });
}
