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

                // Handle success/cancel URLs
                if (url.contains('success')) {
                  widget.onSuccess?.call(url);
                  Navigator.of(context).pop();
                } else if (url.contains('cancel')) {
                  widget.onCancel?.call(url);
                  Navigator.of(context).pop();
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                // Handle navigation requests
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
