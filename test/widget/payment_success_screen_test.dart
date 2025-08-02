import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/payment_success_screen.dart';

void main() {
  group('Payment Success Screen Widget Tests', () {
    testWidgets('Payment success screen should render without crashing', (
      WidgetTester tester,
    ) async {
      // Set a larger test window to avoid overflow
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentSuccessScreen(
            orderId: 'TEST123',
            amount: 100.0,
            paymentMethod: 'Credit Card',
          ),
        ),
      );

      // Just check that the widget renders without crashing
      expect(find.byType(Scaffold), findsOneWidget);

      // Reset
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets('Payment success screen should have basic structure', (
      WidgetTester tester,
    ) async {
      // Set a larger test window to avoid overflow
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentSuccessScreen(
            orderId: 'TEST123',
            amount: 100.0,
            paymentMethod: 'Credit Card',
          ),
        ),
      );

      // Check for basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Container), findsWidgets);

      // Reset
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets('Payment success screen should have success elements', (
      WidgetTester tester,
    ) async {
      // Set a larger test window to avoid overflow
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentSuccessScreen(
            orderId: 'TEST123',
            amount: 100.0,
            paymentMethod: 'Credit Card',
          ),
        ),
      );

      // Check for content elements
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);

      // Reset
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets('Payment success screen should display content', (
      WidgetTester tester,
    ) async {
      // Set a larger test window to avoid overflow
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentSuccessScreen(
            orderId: 'TEST123',
            amount: 100.0,
            paymentMethod: 'Credit Card',
          ),
        ),
      );

      // Check for content elements
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);

      // Reset
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
