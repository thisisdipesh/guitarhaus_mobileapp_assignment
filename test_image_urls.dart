import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();

  // Test the backend server
  try {
    final response = await dio.get('http://localhost:3000/api/v1/test-images');
    print('Backend test response: ${response.data}');
  } catch (e) {
    print('Backend test failed: $e');
  }

  // Test a specific image URL
  try {
    final imageResponse = await dio.get(
      'http://localhost:3000/uploads/IMG-1752931327664.jpg',
    );
    print('Image test response status: ${imageResponse.statusCode}');
    print('Image test response headers: ${imageResponse.headers}');
  } catch (e) {
    print('Image test failed: $e');
  }
}
