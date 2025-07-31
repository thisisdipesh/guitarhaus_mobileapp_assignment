# Stripe Payment Integration Setup Guide

This guide will help you set up Stripe payments in your GuitarHaus Flutter mobile app.

## Prerequisites

1. A Stripe account (sign up at [stripe.com](https://stripe.com))
2. Flutter development environment
3. Backend server running (Node.js/Express)

## Backend Setup

### 1. Install Stripe Dependencies

In your backend directory (`guitarhaus_backend`), install the Stripe package:

```bash
npm install stripe
```

### 2. Configure Environment Variables

Create or update your `.env` file in the backend directory:

```env
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here
```

### 3. Backend Endpoints

The following endpoints are already implemented in your backend:

- `POST /api/v1/orders/create-payment-intent` - Creates payment intent for one-time payments
- `POST /api/v1/guitars/create-checkout-session` - Creates checkout session for subscriptions
- `GET /api/v1/guitars/session/:sessionId` - Gets session details

## Flutter App Setup

### 1. Update Dependencies

The following dependencies are already added to `pubspec.yaml`:

```yaml
dependencies:
  flutter_stripe: 10.1.0
  webview_flutter: ^4.7.0
```

### 2. Configure Stripe Keys

Update the Stripe publishable key in `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Replace with your actual Stripe publishable key
  Stripe.publishableKey = 'pk_test_your_publishable_key_here';
  
  // Configure Stripe settings
  Stripe.merchantIdentifier = 'merchant.com.guitarhaus.app';
  
  runApp(/* your app */);
}
```

### 3. Android Configuration

Add the following to `android/app/src/main/AndroidManifest.xml` inside the `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.gms.wallet.api.enabled"
    android:value="true" />
```

### 4. iOS Configuration

For iOS, you'll need to configure your app's capabilities and add the merchant identifier.

## Features Implemented

### 1. One-Time Payments (Payment Sheet)

- Uses Stripe Payment Sheet for secure card payments
- Handles payment intents
- Automatic error handling and validation
- Success/failure callbacks

### 2. Subscription Payments (Checkout)

- Uses Stripe Checkout for subscription payments
- WebView integration for checkout flow
- Success/cancel handling

### 3. Payment Success Screen

- Beautiful success screen after payment completion
- Order details display
- Navigation options

### 4. Error Handling

- Comprehensive error handling for payment failures
- User-friendly error messages
- Retry mechanisms

## Usage

### Making a Payment

1. Navigate to the checkout screen
2. Fill in shipping details
3. Select "Stripe" as payment method
4. Click "Pay with Stripe"
5. Complete payment in the Stripe Payment Sheet
6. View success screen

### Subscription Payments

1. For guitars with `stripePriceId`, use subscription flow
2. Creates checkout session
3. Opens WebView with Stripe Checkout
4. Handles success/cancel callbacks

## Testing

### Test Cards

Use these test card numbers for testing:

- **Success**: `4242 4242 4242 4242`
- **Decline**: `4000 0000 0000 0002`
- **Requires Authentication**: `4000 0025 0000 3155`

### Test Mode

Make sure you're using test keys (`pk_test_` and `sk_test_`) during development.

## Security Considerations

1. **Never expose secret keys** in client-side code
2. **Always use HTTPS** in production
3. **Validate payments** on the server side
4. **Use webhooks** for payment confirmation
5. **Implement proper error handling**

## Troubleshooting

### Common Issues

1. **Payment Sheet not showing**: Check if Stripe is properly initialized
2. **Network errors**: Verify backend URL and connectivity
3. **Authentication errors**: Ensure proper token handling
4. **WebView issues**: Check webview_flutter installation

### Debug Mode

Enable debug logging in your API service:

```dart
// In ApiService constructor
_dio.interceptors.add(
  PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
    compact: true,
  ),
);
```

## Production Deployment

1. **Switch to live keys** (`pk_live_` and `sk_live_`)
2. **Update merchant identifier** for production
3. **Configure webhooks** for payment events
4. **Test thoroughly** with real payment methods
5. **Monitor payments** in Stripe Dashboard

## Support

For issues related to:
- **Stripe API**: Check [Stripe Documentation](https://stripe.com/docs)
- **Flutter Stripe**: Check [flutter_stripe package](https://pub.dev/packages/flutter_stripe)
- **App-specific issues**: Check the code comments and error logs

## Files Modified/Created

### New Files:
- `lib/core/network/stripe_payment_service.dart` - Stripe payment service
- `lib/core/common/stripe_webview.dart` - WebView for checkout
- `lib/features/auth/presentation/view/payment_success_screen.dart` - Success screen

### Modified Files:
- `lib/main.dart` - Stripe initialization
- `lib/core/network/api_service.dart` - Added Stripe endpoints
- `lib/features/auth/presentation/view/checkout_screen.dart` - Enhanced payment flow
- `pubspec.yaml` - Added dependencies

### Backend Files:
- `guitarhaus_backend/controllers/OrderController.js` - Payment intent creation
- `guitarhaus_backend/routes/OrderRoute.js` - Payment routes

## Next Steps

1. **Test the integration** thoroughly
2. **Add webhook handling** for payment events
3. **Implement payment analytics**
4. **Add payment method management**
5. **Consider adding Apple Pay/Google Pay** 