import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/video.dart';
import '../models/comment.dart';

/// Service untuk memanggil API katalog video (list & detail).
class VideoService {
  /// Base URL server Django kamu
  /// Sekarang mengarah ke: http://127.0.0.1:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  /// GET /videos/api/ (dengan optional filter)
  /// [sportId] - filter by sport ID (optional)
  /// [difficulty] - filter by difficulty: "Pemula", "Menengah", "Lanjutan" (optional)
  static Future<List<Video>> fetchVideos({
    int? sportId,
    String? difficulty,
  }) async {
    final uri = Uri.parse('$baseUrl/videos/api/').replace(
      queryParameters: {
        if (sportId != null) 'sport': sportId.toString(),
        if (difficulty != null && difficulty.isNotEmpty) 'difficulty': difficulty,
      },
    );
    
    final response = await http.get(uri);

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

  /// GET /videos/api/{id}/comments/ - ambil komentar video
  static Future<List<Comment>> fetchComments(int videoId) async {
    final url = Uri.parse('$baseUrl/videos/api/$videoId/comments/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Comment.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      // Kalau endpoint belum ada, return empty list
      if (response.statusCode == 404) {
        return [];
      }
      throw Exception('Gagal memuat komentar (status ${response.statusCode})');
    }
  }

  /// POST /videos/api/{id}/comment/ - tambah komentar
  static Future<Comment> submitComment({
    required int videoId,
    required String text,
    int? rating,
  }) async {
    final url = Uri.parse('$baseUrl/videos/api/$videoId/comment/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
        if (rating != null) 'rating': rating,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return Comment.fromJson(data);
    } else {
      throw Exception('Gagal menambah komentar (status ${response.statusCode})');
    }
  }

  /// POST /videos/api/{id}/rate/ - submit rating video
  static Future<void> submitRating({
    required int videoId,
    required int rating, // 1-5
  }) async {
    final url = Uri.parse('$baseUrl/videos/api/$videoId/rate/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rating': rating}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal menambah rating (status ${response.statusCode})');
    }
  }
}


