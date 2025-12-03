import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/video.dart';

/// Service untuk memanggil API katalog video (list & detail).
class VideoService {
  /// Base URL server Django kamu
  /// Sekarang mengarah ke: http://127.0.0.1:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  /// GET /videos/api/
  static Future<List<Video>> fetchVideos() async {
    final url = Uri.parse('$baseUrl/videos/api/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Video.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat daftar video (status ${response.statusCode})');
    }
  }

  /// GET /videos/api/{id}/
  static Future<Video> fetchVideoDetail(int id) async {
    final url = Uri.parse('$baseUrl/videos/api/$id/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      return Video.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail video (status ${response.statusCode})');
    }
  }
}


