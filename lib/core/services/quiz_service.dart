import 'package:dio/dio.dart';
import 'package:quiz_app/core/services/token_service.dart';

class QuizApiService {
  late Dio dio;

  QuizApiService() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000/quizora/quiz/',
      receiveTimeout: Duration(seconds: 180),
      connectTimeout: Duration(seconds: 90),
      validateStatus: (status) => true,
    ));

    // intercept every request — attach access token automatically
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },

      onResponse: (response, handler) async {
        // if 401, try to refresh then retry
        if (response.statusCode == 401) {
          final refreshed = await _refreshToken();

          if (refreshed) {
            // retry original request with new token
            final newToken = await TokenService.getAccessToken();
            response.requestOptions.headers['Authorization'] = 'Bearer $newToken';

            final retryResponse = await dio.fetch(response.requestOptions);
            return handler.resolve(retryResponse);
          } else {
            // refresh failed — logout user
            await TokenService.clearTokens();

          }
        }

        handler.next(response);
      },

      onError: (error, handler) async {
        handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenService.getRefreshToken();
      if (refreshToken == null) return false;

      // use a separate Dio instance to avoid interceptor loop
      final refreshDio = Dio(BaseOptions(
        baseUrl: 'http://localhost:3000/quizora/',
        validateStatus: (status) => true,
      ));

      final response = await refreshDio.post('auth/refresh-token', options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'}
      ));

      if (response.statusCode == 200) {
        await TokenService.saveAccessTokens( accessToken:response.data['accessToken'],);
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, dynamic data, {bool isMultipart = false}) async {
    print("Request sent");
    try {
      final response = await dio.post(
        endpoint,
        data: data,
        options: Options(
          contentType: isMultipart ? 'multipart/form-data' : 'application/json',
        ),
      );

      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return {"success": false, "message": "Connection timeout. Try again."};
    }
    if (e.type == DioExceptionType.connectionError) {
      return {"success": false, "message": "No internet connection"};
    }
    if (e.response != null) return e.response!.data;
    return {"success": false, "message": "Unexpected error occurred"};
  }
}