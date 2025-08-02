import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeWebView extends StatefulWidget {
  final String checkoutUrl;
  final Function(String)? onSuccess;
  final Function(String)? onCancel;

  const StripeWebView({
    super.key,
    required this.checkoutUrl,
    this.onSuccess,
    this.onCancel,
  });

  @override
  State<StripeWebView> createState() => _StripeWebViewState();
}

class _StripeWebViewState extends State<StripeWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Update loading bar
              },
              onPageStarted: (String url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });

                print('Stripe WebView - Page finished: $url');

                // Handle Stripe success/cancel URLs with more patterns
                if (url.contains('success') ||
                    url.contains('payment_intent_client_secret') ||
                    url.contains('checkout/success') ||
                    url.contains('return_url') ||
                    url.contains('stripe.com/success')) {
                  print('Stripe WebView - Success detected: $url');
                  widget.onSuccess?.call(url);
                  Navigator.of(context).pop();
                } else if (url.contains('cancel') ||
                    url.contains('checkout/cancel') ||
                    url.contains('stripe.com/cancel')) {
                  print('Stripe WebView - Cancel detected: $url');
                  widget.onCancel?.call(url);
                  Navigator.of(context).pop();
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                print('Stripe WebView - Navigation request: ${request.url}');

                // Handle Stripe redirects
                if (request.url.contains('success') ||
                    request.url.contains('payment_intent_client_secret') ||
                    request.url.contains('checkout/success') ||
                    request.url.contains('return_url') ||
                    request.url.contains('stripe.com/success')) {
                  print(
                    'Stripe WebView - Success redirect detected: ${request.url}',
                  );
                  widget.onSuccess?.call(request.url);
                  Navigator.of(context).pop();
                  return NavigationDecision.prevent;
                } else if (request.url.contains('cancel') ||
                    request.url.contains('checkout/cancel') ||
                    request.url.contains('stripe.com/cancel')) {
                  print(
                    'Stripe WebView - Cancel redirect detected: ${request.url}',
                  );
                  widget.onCancel?.call(request.url);
                  Navigator.of(context).pop();
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102840),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102840),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            widget.onCancel?.call('User cancelled');
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Complete Payment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Ubuntu-Bold',
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: const Color(0xFF102840),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFB799FF)),
                    SizedBox(height: 16),
                    Text(
                      'Loading payment page...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
