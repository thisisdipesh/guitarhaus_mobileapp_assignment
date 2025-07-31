import 'package:flutter/material.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/cart_screen.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/favorites_screen.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/profile_screen.dart';
import 'theme/theme.dart'; // ✅ Import the theme
import 'features/auth/presentation/view/login_screen.dart';
import 'features/auth/presentation/view/signup_screen.dart';
import 'features/auth/presentation/view/splash_screen.dart';
import 'features/auth/presentation/view/bottom_navigation_screen/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/favorites_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'features/auth/presentation/view/payment_success_screen.dart';
import 'features/auth/presentation/view/my_orders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe with your publishable key
  Stripe.publishableKey =
      'pk_test_51Rq87wC14naaUubxN4WVucJdAozvCPrwSgdmzceKPC6Hzltw0TrLgWHTjNeBDxG5iQHCqlofgBOGbasQ5vsVBsx400Z4nkf6Fo';

  // Configure Stripe settings
  Stripe.merchantIdentifier = 'merchant.com.guitarhaus.app';

  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoritesProvider(),
      child: GuitarHaus(),
    ),
  );
}

class GuitarHaus extends StatelessWidget {
  const GuitarHaus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuitarHaus',
      debugShowCheckedModeBanner: false,
      theme: appTheme, // ✅ Use centralized theme
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/favorites': (context) => FavoritesScreen(),
        '/profile': (context) => ProfileScreen(),
        '/cart': (context) => CartScreen(),
        '/payment-success':
            (context) => const PaymentSuccessScreen(
              orderId: 'ORDER-123',
              amount: 0.0,
              paymentMethod: 'Stripe',
            ),
        '/my-orders': (context) => MyOrdersScreen(),
      },
    );
  }
}
