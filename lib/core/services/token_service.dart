import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();

  static const _accessTokenKey  = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _roleKey         = 'role';

  // ── Save ──────────────────────────────────────────────────────────────────
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String role,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey,  value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _roleKey,         value: role),
    ]);
  }
  static Future<void> saveAccessTokens({
    required String accessToken,


  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey,  value: accessToken),

    ]);
  }

  // ── Read ──────────────────────────────────────────────────────────────────
  static Future<String?> getAccessToken()  async =>
      _storage.read(key: _accessTokenKey);

  static Future<String?> getRefreshToken() async =>
      _storage.read(key: _refreshTokenKey);

  static Future<String?> getRole() async =>
      _storage.read(key: _roleKey);

  // ── Validation (JWT exp decoded locally — no network needed) ──────────────

  /// Returns true if access token exists and is not expired.
  static Future<bool> isAccessTokenValid() async {
    final token = await getAccessToken();
    if (token == null) return false;
    return _isJwtAlive(token);
  }

  /// Returns true if refresh token exists and is not expired.
  static Future<bool> isRefreshTokenValid() async {
    final token = await getRefreshToken();
    if (token == null) return false;
    return _isJwtAlive(token);
  }

  /// Decodes JWT and checks `exp` claim against current time.
  /// No signature verification — server handles that on actual API calls.
  static bool _isJwtAlive(String token) {
    try {
      final jwt = JWT.decode(token);       // decode only, no verify
      final exp = jwt.payload['exp'];
      if (exp == null) return false;

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

      // Treat as expired 30s early to avoid race conditions
      return DateTime.now().isBefore(
        expiry.subtract(const Duration(seconds: 30)),
      );
    } catch (_) {
      return false; // malformed token
    }
  }

  // ── Clear (on logout) ─────────────────────────────────────────────────────
  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _roleKey),
    ]);
  }
}