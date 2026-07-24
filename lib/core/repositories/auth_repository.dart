import 'package:quiz_app/core/services/auth_service.dart';


class AuthRepository {
   Future<Map<String, dynamic>> login(String email, String password) async {
      return await ApiService().post("login", {
         "email": email,
         "password": password,
      });
   }
   Future<Map<String, dynamic>> signUp(String name,String email, String password,String role) async {
      return await ApiService().post("sign-up", {
         "name":name,
         "email": email,
         "password": password,
         "role":role
      });
   }
   Future<Map<String, dynamic>> verifyOtp(String email, String otp,String role) async {
      print(email+otp+role);
      return await ApiService().post("verify-otp", {

         "email": email,
         "otp": otp,
         "role":role

      });
   }
   Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
      return await ApiService().post("refresh-token", {
         "refresh_token": refreshToken,
      });
   }
   Future<Map<String, dynamic>> logout(String refreshToken) async {
      return await ApiService().post("logout", {
         "refresh_token": refreshToken,
      });
   }
}
