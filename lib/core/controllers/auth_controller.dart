import 'package:quiz_app/core/services/token_service.dart';

import '../repositories/auth_repository.dart';

class AuthController {
  final AuthRepository repository = AuthRepository();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await repository.login(email, password);
      return {
        "success": response['success'],
        "message": response['message'],
        "role":response['role'],
        "accessToken":response['accessToken'],
        "refreshToken":response['refreshToken']
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  Future<Map<String, Object>> signUp(String name,String email, String password,String role) async {
    try {
      final response = await repository.signUp(name,email, password,role);
      print(response);
      return {
        "success": response['success'],
        "message": response['message'],
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  Future<Map<String, Object>> verifyOtp(String email, String otp,String role) async {
    try {
      final response = await repository.verifyOtp(email,otp,role);
      return {
        "success": response['success'],
        "message": response['message'],
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
  // ── Refresh Token (silent, called on app launch) ───────────────────────────
  Future<bool> refreshToken() async {
    try {
      final storedRefreshToken = await TokenService.getRefreshToken();
      final storedRole         = await TokenService.getRole();

      if (storedRefreshToken == null || storedRole == null) return false;

      final response = await repository.refreshToken(storedRefreshToken);

      if (response['success'] == true) {
        await TokenService.saveTokens(
          accessToken:  response['accessToken'],
          refreshToken: response['refreshToken'] ?? storedRefreshToken,
          role:         response['role']          ?? storedRole,
        );
        return true;
      }

      await TokenService.clearTokens();
      return false;

    } catch (e) {
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<Map<String,dynamic>> logout(String refreshToken) async {
    try {
      final response = await repository.logout(refreshToken);
      return {
        "success": response['success'],
        "message": response['message'],
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }

  }
}

