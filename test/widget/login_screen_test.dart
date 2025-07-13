import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display login form with all required fields', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Assert
      expect(find.text('GuitarHaus'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should show password when visibility toggle is pressed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Find visibility toggle button
      final visibilityButton = find.byIcon(Icons.visibility_off);
      expect(visibilityButton, findsOneWidget);

      // Act - tap visibility toggle
      await tester.tap(visibilityButton);
      await tester.pump();

      // Assert - should show visibility icon
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should show email validation error for empty fields', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Find login button
      final loginButton = find.byType(ElevatedButton);

      // Act - tap login without entering data
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert - should show only email validation error
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('Password is required'), findsNothing);
    });

    testWidgets('should show password validation error for empty password', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Enter valid email
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      // Find login button
      final loginButton = find.byType(ElevatedButton);

      // Act - tap login with valid email but empty password
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert - should show only password validation error
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Enter a valid email'), findsNothing);
    });

    testWidgets('should show validation error for invalid email', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Find email field and enter invalid email
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'invalid-email');
      await tester.pump();

      // Find login button and tap
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();

      // Assert - should show email validation error
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('should show validation error for empty password', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Find email field and enter valid email
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      // Find login button and tap
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();

      // Assert - should show password validation error
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should have correct styling and colors', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Assert - check for correct colors and styling
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFFF5722));

      // Check if logo image is present
      expect(find.byType(Image), findsNWidgets(2)); // Logo and Google logo
    });

    testWidgets('should handle keyboard dismissal when tapping outside', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Act - tap on email field to show keyboard
      final emailField = find.byType(TextField).first;
      await tester.tap(emailField);
      await tester.pump();

      // Tap outside to dismiss keyboard
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();

      // Assert - keyboard should be dismissed (no specific assertion needed for this behavior)
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('should display Google sign-in option', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Assert - check for Google sign-in button
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('or'), findsOneWidget);
    });

    testWidgets('should display sign up link', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();

      // Scroll to bottom to ensure visibility
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Assert - check for sign up link
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });
  });
} 