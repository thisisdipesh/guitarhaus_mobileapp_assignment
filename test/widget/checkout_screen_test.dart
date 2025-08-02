import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/checkout_screen.dart';

void main() {
  group('Checkout Screen Widget Tests', () {
    testWidgets('Checkout screen should render without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CheckoutScreen(cartItems: [], totalAmount: 0.0),
        ),
      );

      // Just check that the widget renders without crashing
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Checkout screen should have basic structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CheckoutScreen(cartItems: [], totalAmount: 0.0),
        ),
      );

      // Check for basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Checkout screen should have form elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CheckoutScreen(cartItems: [], totalAmount: 0.0),
        ),
      );

      // Check for form elements
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('Checkout screen should display content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CheckoutScreen(cartItems: [], totalAmount: 0.0),
        ),
      );

      // Check for content elements
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });
  });
}
