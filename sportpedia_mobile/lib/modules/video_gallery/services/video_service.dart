import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/video.dart';
import '../models/comment.dart';

// Note: Using CookieRequest for all platforms (web and mobile)
// CookieRequest handles cookies automatically for both platforms

/// Service untuk memanggil API katalog video (list & detail).
class VideoService {
  /// Base URL server Django - khusus untuk modul video gallery
  /// - Web: http://localhost:8000
  /// - Android Emulator: http://10.0.2.2:8000
  /// - iOS Simulator: http://localhost:8000
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';  // Android emulator
    } else {
      return 'http://localhost:8000';  // iOS simulator atau platform lain
    }
  }

  /// GET /videos/api/ (dengan optional filter)
  /// [sportId] - filter by sport ID (optional)
  /// [difficulty] - filter by difficulty: "Pemula", "Menengah", "Lanjutan" (optional)
  /// [search] - search query untuk title, description, instructor, tags (optional)
  /// [sort] - sort by: "popular", "newest", "rating", "views" (optional)
  /// [request] - CookieRequest untuk authenticated requests (optional, untuk GET tidak wajib)
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
        if (difficulty != null && difficulty.isNotEmpty) 'difficulty': difficulty,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
      },
    );
    
    // Untuk GET request yang tidak perlu auth, pakai http.get() biasa
    // CookieRequest hanya untuk POST request yang perlu session
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) => Video.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Gagal memuat daftar video (status ${response.statusCode})');
      }
    } catch (e) {
      // Jika error, coba dengan CookieRequest sebagai fallback (jika ada)
      if (request != null) {
        try {
          final response = await request.get(uri.toString());
          if (response is List) {
            return response
                .map((json) => Video.fromJson(json as Map<String, dynamic>))
                .toList();
          } else if (response is Map<String, dynamic>) {
            throw Exception('Gagal memuat daftar video: ${response['message'] ?? response['detail'] ?? 'Unknown error'}');
          } else {
            final List<dynamic> data = jsonDecode(response.toString()) as List<dynamic>;
            return data
                .map((json) => Video.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        } catch (e2) {
          throw Exception('Gagal memuat daftar video: $e2');
        }
      }
      rethrow;
    }
  }

  /// GET /videos/api/{id}/
  /// [request] - CookieRequest untuk authenticated requests (optional, untuk GET tidak wajib)
  static Future<Video> fetchVideoDetail(int id, {CookieRequest? request}) async {
    final url = Uri.parse('$baseUrl/videos/api/$id/');
    // Untuk GET request yang tidak perlu auth, pakai http.get() biasa
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        return Video.fromJson(data);
      } else {
        throw Exception('Gagal memuat detail video (status ${response.statusCode})');
      }
    } catch (e) {
      // Jika error, coba dengan CookieRequest sebagai fallback (jika ada)
      if (request != null) {
        try {
          final response = await request.get(url.toString());
          if (response is Map<String, dynamic>) {
            if (response.containsKey('detail') || response.containsKey('error')) {
              throw Exception('Gagal memuat detail video: ${response['detail'] ?? response['error'] ?? 'Unknown error'}');
            }
            return Video.fromJson(response);
          } else {
            final Map<String, dynamic> data = jsonDecode(response.toString()) as Map<String, dynamic>;
            return Video.fromJson(data);
          }
        } catch (e2) {
          throw Exception('Gagal memuat detail video: $e2');
        }
      }
      rethrow;
    }
  }

  /// GET /videos/api/{id}/comments/ - ambil komentar video
  /// [request] - CookieRequest untuk authenticated requests (optional, untuk GET tidak wajib)
  static Future<List<Comment>> fetchComments(int videoId, {CookieRequest? request}) async {
    final url = Uri.parse('$baseUrl/videos/api/$videoId/comments/');
    // Untuk GET request yang tidak perlu auth, pakai http.get() biasa
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
        throw Exception('Gagal memuat komentar (status ${response.statusCode})');
      }
    } catch (e) {
      // Jika error, coba dengan CookieRequest sebagai fallback (jika ada)
      if (request != null) {
        try {
          final response = await request.get(url.toString());
          if (response is List) {
            return response
                .map((json) => Comment.fromJson(json as Map<String, dynamic>))
                .toList();
          } else if (response is Map<String, dynamic>) {
            if (response.containsKey('detail') && response['detail'] == 'Not found') {
              return [];
            }
            throw Exception('Gagal memuat komentar: ${response['message'] ?? response['detail'] ?? 'Unknown error'}');
          } else {
            final List<dynamic> data = jsonDecode(response.toString()) as List<dynamic>;
            return data
                .map((json) => Comment.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        } catch (e2) {
          // If 404 or other error, return empty list
          return [];
        }
      }
      // Jika tidak ada request dan error, return empty list
      return [];
    }
  }

  /// POST /videos/api/{id}/comment/ - tambah komentar
  /// [request] - CookieRequest WAJIB untuk authenticated POST request
  static Future<Comment> submitComment({
    required CookieRequest request,
    required int videoId,
    required String text,
    int? rating,
  }) async {
    // Check if logged in first
    if (!request.loggedIn) {
      throw Exception('Anda harus login terlebih dahulu');
    }
    
    final url = Uri.parse('$baseUrl/videos/api/$videoId/comment/');
    
    try {
      print('[DEBUG] VideoService.submitComment - URL: $url');
      print('[DEBUG] VideoService.submitComment - loggedIn: ${request.loggedIn}');
      
      // Use CookieRequest for all platforms (works for both web and mobile)
      
    final response = await request.post(
      url.toString(),
      jsonEncode({
        'text': text,
        if (rating != null) 'rating': rating,
      }),
    );

      print('[DEBUG] VideoService.submitComment - Response type: ${response.runtimeType}');
      print('[DEBUG] VideoService.submitComment - Response: $response');

    // CookieRequest.post() returns Map<String, dynamic>
    if (response is Map<String, dynamic>) {
      // Check for error
      if (response.containsKey('error') || response.containsKey('detail')) {
          final errorMsg = response['error'] ?? response['detail'] ?? 'Unknown error';
          print('[DEBUG] VideoService.submitComment - Error: $errorMsg');
          print('[DEBUG] VideoService.submitComment - Full error response: $response');
          throw Exception('Gagal menambah komentar: $errorMsg');
      }
      // Success response
      return Comment.fromJson(response);
      } else if (response is String) {
      // If it's a string, try to parse it
        try {
          final Map<String, dynamic> data = jsonDecode(response) as Map<String, dynamic>;
          if (data.containsKey('error') || data.containsKey('detail')) {
            final errorMsg = data['error'] ?? data['detail'] ?? 'Unknown error';
            print('[DEBUG] VideoService.submitComment - Error (string): $errorMsg');
            print('[DEBUG] VideoService.submitComment - Full error response: $data');
            throw Exception('Gagal menambah komentar: $errorMsg');
          }
      return Comment.fromJson(data);
        } catch (e) {
          print('[DEBUG] VideoService.submitComment - Parse error: $e');
          throw Exception('Gagal menambah komentar: Response tidak valid - $response');
        }
      } else {
        print('[DEBUG] VideoService.submitComment - Unknown response type');
        throw Exception('Gagal menambah komentar: Response format tidak dikenali');
      }
    } catch (e, stackTrace) {
      print('[DEBUG] VideoService.submitComment - Exception: $e');
      print('[DEBUG] VideoService.submitComment - StackTrace: $stackTrace');
      // Re-throw dengan pesan yang lebih jelas
      if (e.toString().contains('login') || e.toString().contains('authenticated')) {
        throw Exception('Anda harus login terlebih dahulu');
      }
      rethrow;
    }
  }

  /// POST /videos/api/{id}/rate/ - submit rating video
  /// [request] - CookieRequest WAJIB untuk authenticated POST request
  static Future<void> submitRating({
    required CookieRequest request,
    required int videoId,
    required int rating, // 1-5
  }) async {
    final url = Uri.parse('$baseUrl/videos/api/$videoId/rate/');
    final response = await request.post(
      url.toString(),
      jsonEncode({'rating': rating}),
    );

    // CookieRequest.post() returns Map<String, dynamic>
    if (response is Map<String, dynamic>) {
      // Check for error
      if (response.containsKey('error') || response.containsKey('detail')) {
        throw Exception('Gagal menambah rating: ${response['error'] ?? response['detail'] ?? 'Unknown error'}');
      }
      // Success - no need to return anything
      return;
    }
  }

  /// POST /videos/comment/{comment_id}/helpful/ - Mark comment as helpful
  /// [request] - CookieRequest untuk authenticated POST request
  static Future<int> markCommentHelpful({
    required CookieRequest request,
    required int commentId,
  }) async {
    final url = Uri.parse('$baseUrl/videos/comment/$commentId/helpful/');
    
    try {
      // Use CookieRequest for all platforms
      
      final response = await request.post(
        url.toString(),
        '{}',
      );
      
      if (response is Map<String, dynamic>) {
        if (response.containsKey('error') || response.containsKey('detail')) {
          throw Exception(response['error'] ?? response['detail'] ?? 'Unknown error');
        }
        if (response['success'] == true) {
          return response['helpful_count'] as int;
        }
        throw Exception('Failed to mark as helpful');
      } else if (response is String) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        if (data.containsKey('error')) {
          throw Exception(data['error'] as String);
        }
        if (data['success'] == true) {
          return data['helpful_count'] as int;
        }
        throw Exception('Failed to mark as helpful');
      } else {
        throw Exception('Response format tidak dikenali');
      }
    } catch (e) {
      if (e.toString().contains('Already marked')) {
        throw Exception('Komentar ini sudah ditandai sebagai helpful');
      }
      rethrow;
    }
  }

  /// POST /videos/api/comment/{comment_id}/reply/ - Reply to a comment
  /// [request] - CookieRequest WAJIB untuk authenticated POST request
  static Future<Comment> submitReply({
    required CookieRequest request,
    required int commentId,
    required String text,
  }) async {
    if (!request.loggedIn) {
      throw Exception('Anda harus login terlebih dahulu');
    }
    
    final url = Uri.parse('$baseUrl/videos/api/comment/$commentId/reply/');
    
    try {
      // Use CookieRequest for all platforms
      
      final response = await request.post(
        url.toString(),
        jsonEncode({'text': text}),
      );
      
      if (response is Map<String, dynamic>) {
        if (response.containsKey('error') || response.containsKey('detail')) {
          throw Exception(response['error'] ?? response['detail'] ?? 'Unknown error');
        }
        return Comment.fromJson(response);
      } else if (response is String) {
        final data = jsonDecode(response) as Map<String, dynamic>;
        if (data.containsKey('error')) {
          throw Exception(data['error'] as String);
        }
        return Comment.fromJson(data);
      } else {
        throw Exception('Response format tidak dikenali');
      }
    } catch (e) {
      if (e.toString().contains('login') || e.toString().contains('authenticated')) {
        throw Exception('Anda harus login terlebih dahulu');
      }
      rethrow;
    }
  }

  // ============================================
  // ADMIN CRUD OPERATIONS
  // ============================================

  /// GET /videos/api/sports/ - Get list of sports for dropdown
  static Future<List<Map<String, dynamic>>> fetchSports() async {
    try {
      final uri = Uri.parse('$baseUrl/videos/api/sports/');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((sport) => {
          'id': sport['id'] as int,
          'name': sport['name'] as String,
        }).toList();
      } else {
        throw Exception('Gagal memuat daftar olahraga (status ${response.statusCode})');
      }
    } catch (e) {
      print('[DEBUG] VideoService.fetchSports - Error: $e');
      // Fallback: return hardcoded sports list
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

  /// POST /videos/api/create/ - Create new video (Admin only)
  /// [request] - CookieRequest WAJIB untuk authenticated POST request
  static Future<Video> createVideo({
    required CookieRequest request,
    required String title,
    required String description,
    required int sportId,
    required String difficulty, // "Pemula", "Menengah", "Lanjutan"
    required String videoUrl,
    String? thumbnailUrl,
    String? instructor,
    String? duration,
    List<String>? tags,
  }) async {
    if (!request.loggedIn) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    final url = Uri.parse('$baseUrl/videos/api/create/');
    
    // Use CookieRequest for all platforms
    final response = await request.post(
      url.toString(),
      jsonEncode({
        'title': title,
        'description': description,
        'sport': sportId,
        'difficulty': difficulty,
        'video_url': videoUrl,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        if (instructor != null) 'instructor': instructor,
        if (duration != null) 'duration': duration,
        if (tags != null) 'tags': tags,
      }),
    );

    if (response is Map<String, dynamic>) {
      if (response.containsKey('error') || response.containsKey('detail')) {
        throw Exception('Gagal membuat video: ${response['error'] ?? response['detail'] ?? 'Unknown error'}');
      }
      return Video.fromJson(response);
    } else {
      throw Exception('Gagal membuat video: Response format tidak dikenali');
    }
  }

  /// POST /videos/api/{id}/update/ - Update video (Admin only)
  /// [request] - CookieRequest WAJIB untuk authenticated POST request
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
    print('[DEBUG] VideoService.updateVideo - loggedIn: ${request.loggedIn}');
    print('[DEBUG] VideoService.updateVideo - URL: $baseUrl/videos/api/$videoId/update/');
    
    if (!request.loggedIn) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    final url = Uri.parse('$baseUrl/videos/api/$videoId/update/');
    
    // Use CookieRequest for all platforms
    final response = await request.post(
      url.toString(),
      jsonEncode({
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (sportId != null) 'sport': sportId,
        if (difficulty != null) 'difficulty': difficulty,
        if (videoUrl != null) 'video_url': videoUrl,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        if (instructor != null) 'instructor': instructor,
        if (duration != null) 'duration': duration,
        if (tags != null) 'tags': tags,
      }),
    );

    if (response is Map<String, dynamic>) {
      if (response.containsKey('error') || response.containsKey('detail')) {
        throw Exception('Gagal mengupdate video: ${response['error'] ?? response['detail'] ?? 'Unknown error'}');
      }
      return Video.fromJson(response);
    } else {
      throw Exception('Gagal mengupdate video: Response format tidak dikenali');
    }
  }

  /// POST /videos/api/{id}/delete/ - Delete video (Admin only)
  /// [request] - CookieRequest WAJIB untuk authenticated POST request
  static Future<void> deleteVideo({
    required CookieRequest request,
    required int videoId,
  }) async {
    if (!request.loggedIn) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    final url = Uri.parse('$baseUrl/videos/api/$videoId/delete/');
    
    // Use CookieRequest for all platforms
    final response = await request.post(
      url.toString(),
      jsonEncode({}),
    );

    if (response is Map<String, dynamic>) {
      if (response.containsKey('error') || response.containsKey('detail')) {
        throw Exception('Gagal menghapus video: ${response['error'] ?? response['detail'] ?? 'Unknown error'}');
      }
      return;
    } else {
      throw Exception('Gagal menghapus video: Response format tidak dikenali');
    }
  }
}


