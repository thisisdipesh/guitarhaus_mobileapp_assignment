import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StripePaymentService {
  static const String baseUrl = 'http://10.0.2.2:3003/api/v1';
  late Dio _dio;

  StripePaymentService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  // Set auth token for authenticated requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Create payment intent for one-time payments
  Future<String> createPaymentIntent(double amount, String currency) async {
    try {
      print('Making request to create payment intent: $amount $currency');
      final response = await _dio.post(
        '/orders/create-payment-intent',
        data: {'amount': amount, 'currency': currency},
      );

      print('Payment intent response status: ${response.statusCode}');
      print('Payment intent response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['clientSecret'];
      } else {
        throw Exception(
          'Failed to create payment intent: ${response.data['message']}',
        );
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      throw Exception('Error creating payment intent: $e');
    }
  }

  // Create checkout session for subscription payments
  Future<String> createCheckoutSession(String priceId) async {
    try {
      final response = await _dio.post(
        '/guitars/create-checkout-session',
        data: {'priceId': priceId},
      );

      if (response.statusCode == 200) {
        return response.data['url'];
      } else {
        throw Exception('Failed to create checkout session');
      }
    } catch (e) {
      throw Exception('Error creating checkout session: $e');
    }
  }

  // Get session details
  Future<Map<String, dynamic>> getSessionDetails(String sessionId) async {
    try {
      final response = await _dio.get('/guitars/session/$sessionId');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get session details');
      }
    } catch (e) {
      throw Exception('Error getting session details: $e');
    }
  }

  // Process one-time payment using Stripe Payment Sheet
  Future<PaymentResult> processPayment(double amount, String currency) async {
    try {
      print('Starting Stripe payment process for amount: $amount $currency');

      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        setAuthToken(token);
        print('Auth token set successfully');
      } else {
        print('No auth token found');
      }

      // Create payment intent
      print('Creating payment intent...');
      final clientSecret = await createPaymentIntent(amount, currency);
      print(
        'Payment intent created with client secret: ${clientSecret.substring(0, 20)}...',
      );

      // Check if this is a simulated payment intent (for testing)
      if (clientSecret.startsWith('pi_simulated_secret_')) {
        // For testing, try to open Stripe payment sheet with a demo client secret
        print(
          'Simulated payment intent detected - opening Stripe payment sheet',
        );

        // Use a demo client secret that will work with Stripe's test mode
        // This is a sample client secret for testing purposes
        const demoClientSecret =
            'pi_3OQXXXXXXXXXXXXX_secret_XXXXXXXXXXXXXXXXXXXXXXXX';

        try {
          // Configure payment sheet with demo client secret
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: demoClientSecret,
              merchantDisplayName: 'GuitarHaus',
            ),
          );

          // Present payment sheet
          await Stripe.instance.presentPaymentSheet();

          return PaymentResult(
            success: true,
            message: 'Payment completed successfully (Demo Mode)',
          );
        } catch (e) {
          print('Error with demo payment sheet: $e');
          // Show a dialog explaining that this is a demo
          return PaymentResult(
            success: false,
            message:
                'This is a demo app. In a real app, you would see the Stripe payment sheet here.',
          );
        }
      }

      // Configure payment sheet
      print('Initializing payment sheet...');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'GuitarHaus',
        ),
      );
      print('Payment sheet initialized successfully');

      // Present payment sheet
      print('Presenting payment sheet...');
      await Stripe.instance.presentPaymentSheet();
      print('Payment sheet presented successfully');

      return PaymentResult(
        success: true,
        message: 'Payment completed successfully',
      );
    } catch (e) {
      print('Stripe payment error: $e');
      if (e is StripeException) {
        return PaymentResult(
          success: false,
          message: e.error.localizedMessage ?? 'Payment failed',
          errorCode: e.error.code.toString(),
        );
      } else {
        return PaymentResult(success: false, message: e.toString());
      }
    }
  }

  // Process subscription payment using Stripe Checkout
  Future<PaymentResult> processSubscription(String priceId) async {
    try {
      // Create checkout session
      final checkoutUrl = await createCheckoutSession(priceId);

      // Open checkout URL in web view or browser
      // Note: For mobile apps, you might want to use a WebView
      // For now, we'll return the URL to be handled by the UI
      return PaymentResult(
        success: true,
        message: 'Checkout session created',
        checkoutUrl: checkoutUrl,
      );
    } catch (e) {
      return PaymentResult(success: false, message: e.toString());
    }
  }

  // Confirm payment intent (for additional verification if needed)
  Future<bool> confirmPayment(String paymentIntentId) async {
    try {
      final response = await _dio.post(
        '/orders/confirm-payment',
        data: {'paymentIntentId': paymentIntentId},
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}

// Payment result class
class PaymentResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? checkoutUrl;

  PaymentResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.checkoutUrl,
  });
}
