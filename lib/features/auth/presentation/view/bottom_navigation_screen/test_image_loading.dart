import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ImageLoadingTest extends StatefulWidget {
  const ImageLoadingTest({super.key});

  @override
  State<ImageLoadingTest> createState() => _ImageLoadingTestState();
}

class _ImageLoadingTestState extends State<ImageLoadingTest> {
  String? testResult;
  bool isLoading = false;

  Future<void> testImageLoading() async {
    setState(() {
      isLoading = true;
      testResult = null;
    });

    try {
      final dio = Dio();

      // Test 1: Check if server is reachable
      print('🔍 Testing server connectivity...');
      final serverResponse = await dio.get(
        'http://10.0.2.2:3003/api/v1/test-images',
      );
      print('✅ Server response: ${serverResponse.statusCode}');

      // Test 2: Check specific image
      print('🔍 Testing image loading...');
      final imageResponse = await dio.get(
        'http://10.0.2.2:3003/uploads/IMG-1754069004097.jpeg',
      );
      print('✅ Image response: ${imageResponse.statusCode}');
      print('✅ Image content length: ${imageResponse.data.length}');

      setState(() {
        testResult = '✅ SUCCESS: Server and image loading working correctly!';
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        testResult = '❌ ERROR: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Loading Test'),
        backgroundColor: const Color(0xFFB799FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : testImageLoading,
              child: Text(isLoading ? 'Testing...' : 'Test Image Loading'),
            ),
            const SizedBox(height: 20),
            if (testResult != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      testResult!.contains('SUCCESS')
                          ? Colors.green[100]
                          : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(testResult!),
              ),
            const SizedBox(height: 20),
            const Text('Testing network image loading:'),
            Image.network(
              'http://10.0.2.2:3003/uploads/IMG-1754069004097.jpeg',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.red[100],
                  child: const Icon(Icons.error, color: Colors.red, size: 50),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
