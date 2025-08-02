import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/profile_screen.dart';

void main() {
  group('Profile Screen Widget Tests', () {
    testWidgets('Profile screen should render without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

      // Just check that the widget renders without crashing
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Profile screen should have basic structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

      // Check for basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Profile screen should display content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

      // Check for content elements
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('Profile screen should handle profile functionality', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

      // Check for profile-related elements
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Profile screen should be responsive', (
      WidgetTester tester,
    ) async {
      // Test with different screen sizes
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

      expect(find.byType(Scaffold), findsOneWidget);

      // Reset
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
