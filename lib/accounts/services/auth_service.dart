import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  static String get baseUrl =>
      kIsWeb ? "http://localhost:8000" : "http://10.0.2.2:8000";

  static Future<Map<String, dynamic>> login(
      CookieRequest req, String username, String password) async {
    final endpoint = "$baseUrl/accounts/api/login/";

    return await req.login(endpoint, {
      "username": username,
      "password": password,
    });
  }
}
