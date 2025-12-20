import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/video.dart';
import '../models/comment.dart';

class VideoService {
  /// Base URL server Django kamu.
  ///
  /// PENTING:
  /// 1. Jika running di Android Emulator, gunakan 'https://ainur-fadhil-sportpedia.pbp.cs.ui.ac.id/'
  /// 2. Jika build APK Release (untuk HP fisik), GANTI ini dengan URL deployment PBP kamu
  ///    (contoh: 'https://nama-proyek-kamu.pbp.cs.ui.ac.id')
  static String get baseUrl {
    return 'https://ainur-fadhil-sportpedia.pbp.cs.ui.ac.id';
  }

  /// GET /videos/api/ (dengan optional filter)
  static Future<List<Video>> fetchVideos({
    int? sportId,
    String? difficulty,
    String? search,
    String? sort,
    CookieRequest? request,
  }) async {
    final uri = Uri.parse('$baseUrl/videos/api/').replace(
      queryParameters: {
        if (sportId != null) 'sport': sportId.toString(),
        if (difficulty != null && difficulty.isNotEmpty)
          'difficulty': difficulty,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
      },
    );

    try {
      // Prioritaskan request biasa untuk GET publik
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) => Video.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Gagal memuat daftar video (status ${response.statusCode})');
      }
    } catch (e) {
      // Fallback menggunakan CookieRequest jika tersedia
      if (request != null) {
        try {
          final response = await request.get(uri.toString());
          if (response is List) {
            return response
                .map((json) => Video.fromJson(json as Map<String, dynamic>))
                .toList();
          } else {
            // Handle jika response bukan list (misal error map)
            throw Exception('Format data tidak valid');
          }
        } catch (e2) {
          throw Exception('Gagal memuat daftar video: $e2');
        }
      }
      rethrow;
    }
  }

  /// GET /videos/api/{id}/
  static Future<Video> fetchVideoDetail(int id,
      {CookieRequest? request}) async {
    final url = Uri.parse('$baseUrl/videos/api/$id/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Video.fromJson(data);
      } else {
        throw Exception(
            'Gagal memuat detail video (status ${response.statusCode})');
      }
    } catch (e) {
      if (request != null) {
        try {
          final response = await request.get(url.toString());
          if (response is Map<String, dynamic>) {
            if (response.containsKey('error') ||
                response.containsKey('detail')) {
              throw Exception(response['error'] ?? response['detail']);
            }
            return Video.fromJson(response);
          }
        } catch (e2) {
          throw Exception('Gagal memuat detail video: $e2');
        }
      }
      rethrow;
    }
  }

  /// GET /videos/api/{id}/comments/
  static Future<List<Comment>> fetchComments(int videoId,
      {CookieRequest? request}) async {
    final url = Uri.parse('$baseUrl/videos/api/$videoId/comments/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) => Comment.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Gagal memuat komentar (status ${response.statusCode})');
      }
    } catch (e) {
      if (request != null) {
        try {
          final response = await request.get(url.toString());
          if (response is List) {
            return response
                .map((json) => Comment.fromJson(json as Map<String, dynamic>))
                .toList();
          }
          return [];
        } catch (_) {
          return [];
        }
      }
      return [];
    }
  }

  /// POST /videos/api/{id}/comment/
  static Future<Comment> submitComment({
    required CookieRequest request,
    required int videoId,
    required String text,
    int? rating,
  }) async {
    if (!request.loggedIn) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    final url = '$baseUrl/videos/api/$videoId/comment/';
    final Map<String, dynamic> requestBody = {
      'text': text,
      if (rating != null) 'rating': rating,
    };

    try {
      final response = await request.post(url, jsonEncode(requestBody));

      if (response['error'] != null || response['detail'] != null) {
        throw Exception(response['error'] ?? response['detail']);
      }
      return Comment.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menambah komentar: $e');
    }
  }

  /// POST /videos/api/{id}/rate/
  static Future<void> submitRating({
    required CookieRequest request,
    required int videoId,
    required int rating,
  }) async {
    final url = '$baseUrl/videos/api/$videoId/rate/';
    final response = await request.post(url, jsonEncode({'rating': rating}));

    if (response['error'] != null || response['detail'] != null) {
      throw Exception(
          'Gagal menambah rating: ${response['error'] ?? response['detail']}');
    }
  }

  /// POST /videos/comment/{comment_id}/helpful/
  static Future<int> markCommentHelpful({
    required CookieRequest request,
    required int commentId,
  }) async {
    final url = '$baseUrl/videos/comment/$commentId/helpful/';

    try {
      // Mengirim empty JSON object karena request.post mengharapkan body
      final response = await request.post(url, jsonEncode({}));

      if (response['success'] == true) {
        return response['helpful_count'] as int;
      } else {
        throw Exception(response['error'] ?? 'Gagal menandai helpful');
      }
    } catch (e) {
      if (e.toString().contains('Already marked')) {
        throw Exception('Komentar ini sudah ditandai sebagai helpful');
      }
      rethrow;
    }
  }

  /// POST /videos/api/comment/{comment_id}/reply/
  static Future<Comment> submitReply({
    required CookieRequest request,
    required int commentId,
    required String text,
  }) async {
    if (!request.loggedIn) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    final url = '$baseUrl/videos/api/comment/$commentId/reply/';

    try {
      final response = await request.post(url, jsonEncode({'text': text}));

      if (response['error'] != null) {
        throw Exception(response['error']);
      }
      return Comment.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // ADMIN CRUD OPERATIONS
  // ============================================

  /// GET /videos/api/sports/
  static Future<List<Map<String, dynamic>>> fetchSports() async {
    try {
      final uri = Uri.parse('$baseUrl/videos/api/sports/');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((sport) => {
                  'id': sport['id'] as int,
                  'name': sport['name'] as String,
                })
            .toList();
      } else {
        throw Exception('Gagal memuat daftar olahraga');
      }
    } catch (e) {
      // Fallback hardcoded jika API gagal
      return [
        {'id': 1, 'name': 'Bulu Tangkis'},
        {'id': 2, 'name': 'Yoga'},
        {'id': 3, 'name': 'Tenis'},
        {'id': 4, 'name': 'Renang'},
        {'id': 5, 'name': 'Panahan'},
        {'id': 6, 'name': 'Lari'},
        {'id': 7, 'name': 'Basket'},
        {'id': 8, 'name': 'Futsal'},
        {'id': 9, 'name': 'Bersepeda'},
        {'id': 10, 'name': 'Tenis Meja'},
      ];
    }
  }

  /// POST /videos/api/create/
  static Future<Video> createVideo({
    required CookieRequest request,
    required String title,
    required String description,
    required int sportId,
    required String difficulty,
    required String videoUrl,
    String? thumbnailUrl,
    String? instructor,
    String? duration,
    List<String>? tags,
  }) async {
    if (!request.loggedIn) throw Exception('Anda harus login terlebih dahulu');

    final url = '$baseUrl/videos/api/create/';
    final body = {
      'title': title,
      'description': description,
      'sport': sportId,
      'difficulty': difficulty,
      'video_url': videoUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (instructor != null) 'instructor': instructor,
      if (duration != null) 'duration': duration,
      if (tags != null) 'tags': tags,
    };

    final response = await request.post(url, jsonEncode(body));

    if (response['error'] != null || response['detail'] != null) {
      throw Exception(
          'Gagal membuat video: ${response['error'] ?? response['detail']}');
    }
    return Video.fromJson(response);
  }

  /// POST /videos/api/{id}/update/
  static Future<Video> updateVideo({
    required CookieRequest request,
    required int videoId,
    String? title,
    String? description,
    int? sportId,
    String? difficulty,
    String? videoUrl,
    String? thumbnailUrl,
    String? instructor,
    String? duration,
    List<String>? tags,
  }) async {
    if (!request.loggedIn) throw Exception('Anda harus login terlebih dahulu');

    final url = '$baseUrl/videos/api/$videoId/update/';
    final body = {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (sportId != null) 'sport': sportId,
      if (difficulty != null) 'difficulty': difficulty,
      if (videoUrl != null) 'video_url': videoUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (instructor != null) 'instructor': instructor,
      if (duration != null) 'duration': duration,
      if (tags != null) 'tags': tags,
    };

    final response = await request.post(url, jsonEncode(body));

    if (response['error'] != null || response['detail'] != null) {
      throw Exception(
          'Gagal mengupdate video: ${response['error'] ?? response['detail']}');
    }
    return Video.fromJson(response);
  }

  /// POST /videos/api/{id}/delete/
  static Future<void> deleteVideo({
    required CookieRequest request,
    required int videoId,
  }) async {
    if (!request.loggedIn) throw Exception('Anda harus login terlebih dahulu');

    final url = '$baseUrl/videos/api/$videoId/delete/';
    final response = await request.post(url, jsonEncode({}));

    if (response['error'] != null || response['detail'] != null) {
      throw Exception(
          'Gagal menghapus video: ${response['error'] ?? response['detail']}');
    }
  }
}
