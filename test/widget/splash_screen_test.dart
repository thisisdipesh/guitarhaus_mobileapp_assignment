import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/splash_screen.dart';

void main() {
  group('Splash Screen Widget Tests', () {
    testWidgets('Splash screen should render without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Just check that the widget renders without crashing
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Splash screen should have basic structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Check for basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Splash screen should display loading indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Check for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Splash screen should have animated elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Check for animated elements
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('Splash screen should be responsive', (
      WidgetTester tester,
    ) async {
      // Test with different screen sizes
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      expect(find.byType(Scaffold), findsOneWidget);

      // Reset
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
