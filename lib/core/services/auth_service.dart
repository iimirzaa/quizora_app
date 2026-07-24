import 'package:dio/dio.dart';

class ApiService {
  Dio dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000/quizora/auth/',
      receiveTimeout: Duration(seconds: 180),
      connectTimeout: Duration(seconds: 90),
      validateStatus: (status) {
        return true;
      }
  ));

  Future<Map<String, dynamic>> post(String endpoint, Map data) async {
    print("request sent");
    try {
      final response = await dio.post(endpoint, data: data);
      print("Response received");

      return response.data;

    } on DioException catch (e) {
      print("ERROR TYPE: ${e.type}");
      print("ERROR MESSAGE: ${e.message}");

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {
          "success": false,
          "message": "Connection timeout. Try again."
        };
      }

      if (e.type == DioExceptionType.connectionError) {
        return {
          "success": false,
          "message": "No internet connection"
        };
      }

      // If server responded with error (400, 500)
      if (e.response != null) {
        return e.response!.data;
      }

      return {
        "success": false,
        "message": "Unexpected error occurred"
      };
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      return e.response?.data;
    }
  }

}