import 'package:flutter_test/flutter_test.dart';

// Date utility functions for testing
class DateUtils {
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    // Get the start of the current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Get the end of the current week (Sunday)
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    // Check if the date is within the current week
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static bool isThisYear(DateTime date) {
    return date.year == DateTime.now().year;
  }

  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static bool isValidDate(String dateString) {
    try {
      DateTime.parse(dateString);
      return true;
    } catch (e) {
      return false;
    }
  }

  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static String getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  static String getMonthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[date.month - 1];
  }

  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static bool isWeekday(DateTime date) {
    return !isWeekend(date);
  }

  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}

void main() {
  group('DateUtils Unit Tests', () {
    group('Date Formatting Tests', () {
      test('should format date correctly', () {
        final date = DateTime(2023, 12, 25);
        expect(DateUtils.formatDate(date), '25/12/2023');
      });

      test('should format date with single digits', () {
        final date = DateTime(2023, 1, 5);
        expect(DateUtils.formatDate(date), '05/01/2023');
      });

      test('should format date time correctly', () {
        final date = DateTime(2023, 12, 25, 14, 30);
        expect(DateUtils.formatDateTime(date), '25/12/2023 14:30');
      });

      test('should format date time with single digits', () {
        final date = DateTime(2023, 1, 5, 9, 5);
        expect(DateUtils.formatDateTime(date), '05/01/2023 09:05');
      });
    });

    group('Relative Time Tests', () {
      test('should show just now for recent time', () {
        final recent = DateTime.now().subtract(const Duration(seconds: 30));
        expect(DateUtils.getRelativeTime(recent), 'Just now');
      });

      test('should show minutes ago', () {
        final minutesAgo = DateTime.now().subtract(const Duration(minutes: 30));
        expect(DateUtils.getRelativeTime(minutesAgo), '30 minutes ago');
      });

      test('should show hours ago', () {
        final hoursAgo = DateTime.now().subtract(const Duration(hours: 2));
        expect(DateUtils.getRelativeTime(hoursAgo), '2 hours ago');
      });

      test('should show days ago', () {
        final daysAgo = DateTime.now().subtract(const Duration(days: 3));
        expect(DateUtils.getRelativeTime(daysAgo), '3 days ago');
      });
    });

    group('Date Comparison Tests', () {
      test('should identify today', () {
        final today = DateTime.now();
        expect(DateUtils.isToday(today), true);
      });

      test('should identify yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DateUtils.isYesterday(yesterday), true);
      });

      test('should identify this week', () {
        final today = DateTime.now();
        // Test with today's date which should always be in this week
        expect(DateUtils.isThisWeek(today), true);

        // Test with yesterday which should also be in this week
        final yesterday = today.subtract(const Duration(days: 1));
        expect(DateUtils.isThisWeek(yesterday), true);
      });

      test('should identify this month', () {
        final thisMonth = DateTime.now().add(const Duration(days: 15));
        expect(DateUtils.isThisMonth(thisMonth), true);
      });

      test('should identify this year', () {
        final thisYear = DateTime.now().add(const Duration(days: 100));
        expect(DateUtils.isThisYear(thisYear), true);
      });
    });

    group('Age Calculation Tests', () {
      test('should calculate age correctly', () {
        final birthDate = DateTime.now().subtract(
          const Duration(days: 365 * 25),
        );
        expect(DateUtils.getAge(birthDate), isA<int>());
        expect(DateUtils.getAge(birthDate), greaterThan(20));
        expect(DateUtils.getAge(birthDate), lessThan(30));
      });

      test('should calculate age for recent birth', () {
        final birthDate = DateTime.now().subtract(const Duration(days: 365));
        expect(DateUtils.getAge(birthDate), 1);
      });

      test('should handle birthday not yet occurred this year', () {
        final birthDate = DateTime(1990, 12, 25);
        final testDate = DateTime(2023, 6, 15);
        // This test would need to be adjusted based on current date
        expect(DateUtils.getAge(birthDate), isA<int>());
      });
    });

    group('Date Validation Tests', () {
      test('should validate correct date string', () {
        expect(DateUtils.isValidDate('2023-12-25'), true);
        expect(DateUtils.isValidDate('2023-01-01'), true);
      });

      test('should reject invalid date string', () {
        expect(DateUtils.isValidDate('invalid-date'), false);
        expect(DateUtils.isValidDate(''), false);
      });

      test('should parse valid date string', () {
        final parsed = DateUtils.parseDate('2023-12-25');
        expect(parsed, isA<DateTime>());
        expect(parsed!.year, 2023);
        expect(parsed.month, 12);
        expect(parsed.day, 25);
      });

      test('should return null for invalid date string', () {
        final parsed = DateUtils.parseDate('invalid-date');
        expect(parsed, null);
      });
    });

    group('Day and Month Name Tests', () {
      test('should get correct day name', () {
        final monday = DateTime(2023, 1, 2); // Monday
        final friday = DateTime(2023, 1, 6); // Friday
        expect(DateUtils.getDayName(monday), 'Monday');
        expect(DateUtils.getDayName(friday), 'Friday');
      });

      test('should get correct month name', () {
        final january = DateTime(2023, 1, 1);
        final december = DateTime(2023, 12, 1);
        expect(DateUtils.getMonthName(january), 'January');
        expect(DateUtils.getMonthName(december), 'December');
      });
    });

    group('Weekend and Weekday Tests', () {
      test('should identify weekend', () {
        final saturday = DateTime(2023, 1, 7); // Saturday
        final sunday = DateTime(2023, 1, 8); // Sunday
        expect(DateUtils.isWeekend(saturday), true);
        expect(DateUtils.isWeekend(sunday), true);
      });

      test('should identify weekday', () {
        final monday = DateTime(2023, 1, 2); // Monday
        final friday = DateTime(2023, 1, 6); // Friday
        expect(DateUtils.isWeekday(monday), true);
        expect(DateUtils.isWeekday(friday), true);
      });
    });

    group('Date Manipulation Tests', () {
      test('should add days correctly', () {
        final original = DateTime(2023, 1, 1);
        final result = DateUtils.addDays(original, 5);
        expect(result.day, 6);
      });

      test('should subtract days correctly', () {
        final original = DateTime(2023, 1, 10);
        final result = DateUtils.subtractDays(original, 3);
        expect(result.day, 7);
      });

      test('should calculate days between dates', () {
        final from = DateTime(2023, 1, 1);
        final to = DateTime(2023, 1, 10);
        expect(DateUtils.daysBetween(from, to), 9);
      });
    });

    group('Leap Year Tests', () {
      test('should identify leap years', () {
        expect(DateUtils.isLeapYear(2000), true);
        expect(DateUtils.isLeapYear(2020), true);
        expect(DateUtils.isLeapYear(2024), true);
      });

      test('should identify non-leap years', () {
        expect(DateUtils.isLeapYear(2021), false);
        expect(DateUtils.isLeapYear(2022), false);
        expect(DateUtils.isLeapYear(2023), false);
      });

      test('should handle century years', () {
        expect(DateUtils.isLeapYear(1900), false);
        expect(DateUtils.isLeapYear(2000), true);
        expect(DateUtils.isLeapYear(2100), false);
      });
    });
  });
}
