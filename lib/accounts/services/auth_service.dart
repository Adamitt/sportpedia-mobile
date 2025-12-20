import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../config/api_config.dart';

class AuthService {
  // Menggunakan ApiConfig.baseUrl untuk konsistensi
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> login(
      CookieRequest req, String username, String password) async {
    final endpoint = "$baseUrl/accounts/api/login/";

    return await req.login(endpoint, {
      "username": username,
      "password": password,
    });
  }
}
