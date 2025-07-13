import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add logging interceptor for debugging
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      compact: true,
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        // You can get this from shared preferences or secure storage
        // options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle common errors
        if (error.response?.statusCode == 401) {
          // Handle unauthorized
        }
        handler.next(error);
      },
    ));
  }

  // Authentication endpoints
  Future<Response> login(String email, String password) async {
    return await _dio.post('/customers/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> userData) async {
    return await _dio.post('/customers/register', data: userData);
  }

  Future<Response> getUserProfile(String userId) async {
    return await _dio.get('/customers/getCustomer/$userId');
  }

  Future<Response> updateUserProfile(String userId, Map<String, dynamic> userData) async {
    return await _dio.put('/customers/updateCustomer/$userId', data: userData);
  }

  // Guitar endpoints
  Future<Response> getGuitars({
    int? page,
    int? limit,
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? available,
    String? search,
    String? sort,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (category != null) queryParams['category'] = category;
    if (brand != null) queryParams['brand'] = brand;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (available != null) queryParams['available'] = available;
    if (search != null) queryParams['search'] = search;
    if (sort != null) queryParams['sort'] = sort;

    return await _dio.get('/guitars', queryParameters: queryParams);
  }

  Future<Response> getGuitar(String guitarId) async {
    return await _dio.get('/guitars/$guitarId');
  }

  Future<Response> getFeaturedGuitars() async {
    return await _dio.get('/guitars/featured');
  }

  Future<Response> getGuitarsByCategory(String category) async {
    return await _dio.get('/guitars/category/$category');
  }

  Future<Response> searchGuitars(String query) async {
    return await _dio.get('/guitars/search', queryParameters: {'q': query});
  }

  // Cart endpoints
  Future<Response> getCart() async {
    return await _dio.get('/cart');
  }

  Future<Response> addToCart(String guitarId, int quantity) async {
    return await _dio.post('/cart/add', data: {
      'guitarId': guitarId,
      'quantity': quantity,
    });
  }

  Future<Response> updateCartItem(String itemId, int quantity) async {
    return await _dio.put('/cart/update/$itemId', data: {
      'quantity': quantity,
    });
  }

  Future<Response> removeFromCart(String itemId) async {
    return await _dio.delete('/cart/remove/$itemId');
  }

  Future<Response> clearCart() async {
    return await _dio.delete('/cart/clear');
  }

  // Order endpoints
  Future<Response> createOrder(Map<String, dynamic> orderData) async {
    return await _dio.post('/orders', data: orderData);
  }

  Future<Response> getUserOrders() async {
    return await _dio.get('/orders');
  }

  Future<Response> getOrder(String orderId) async {
    return await _dio.get('/orders/$orderId');
  }

  Future<Response> cancelOrder(String orderId) async {
    return await _dio.put('/orders/$orderId/cancel');
  }

  // Wishlist endpoints
  Future<Response> getWishlist() async {
    return await _dio.get('/wishlist');
  }

  Future<Response> addToWishlist(String guitarId) async {
    return await _dio.post('/wishlist/add', data: {
      'guitarId': guitarId,
    });
  }

  Future<Response> removeFromWishlist(String guitarId) async {
    return await _dio.delete('/wishlist/remove/$guitarId');
  }

  Future<Response> checkWishlist(String guitarId) async {
    return await _dio.get('/wishlist/check/$guitarId');
  }

  Future<Response> clearWishlist() async {
    return await _dio.delete('/wishlist/clear');
  }

  // Review endpoints
  Future<Response> getGuitarReviews(String guitarId) async {
    return await _dio.get('/reviews/guitar/$guitarId');
  }

  Future<Response> addReview(String guitarId, Map<String, dynamic> reviewData) async {
    return await _dio.post('/reviews/guitar/$guitarId', data: reviewData);
  }

  Future<Response> updateReview(String reviewId, Map<String, dynamic> reviewData) async {
    return await _dio.put('/reviews/$reviewId', data: reviewData);
  }

  Future<Response> deleteReview(String reviewId) async {
    return await _dio.delete('/reviews/$reviewId');
  }

  Future<Response> getUserReviews() async {
    return await _dio.get('/reviews/user');
  }

  // Helper method to set auth token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Helper method to clear auth token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
} 