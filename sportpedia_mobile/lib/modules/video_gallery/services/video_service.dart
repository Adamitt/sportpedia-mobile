import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/video.dart';
import '../models/comment.dart';

// Conditional import for web
import 'dart:html' as html if (dart.library.html) 'dart:html';

/// Service untuk memanggil API katalog video (list & detail).
class VideoService {
  /// Base URL server Django kamu
  /// Untuk Flutter Web, gunakan localhost agar cookie bisa terkirim (same-origin)
  /// Untuk Android Emulator, gunakan 10.0.2.2:8000
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';  // Use localhost for web to match Flutter Web origin
    }
    return 'http://127.0.0.1:8000';  // Use 127.0.0.1 for mobile
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
      
      // For Flutter Web, use XMLHttpRequest directly with withCredentials
      if (kIsWeb) {
        print('[DEBUG] VideoService.submitComment - Using XMLHttpRequest for Flutter Web with credentials');
        
        try {
          // Use XMLHttpRequest directly to ensure cookies are sent
          final xhr = html.HttpRequest();
          final completer = Completer<Comment>();
          
          xhr.open('POST', url.toString(), async: true);
          xhr.setRequestHeader('Content-Type', 'application/json');
          xhr.withCredentials = true; // CRITICAL: This ensures cookies are sent
          
          xhr.onLoad.listen((event) {
            print('[DEBUG] VideoService.submitComment - XHR response status: ${xhr.status}');
            if (xhr.status == 200 || xhr.status == 201) {
              try {
                final data = jsonDecode(xhr.responseText!) as Map<String, dynamic>;
                completer.complete(Comment.fromJson(data));
              } catch (e) {
                completer.completeError(Exception('Gagal memparse response: $e'));
              }
            } else {
              try {
                final errorData = jsonDecode(xhr.responseText ?? '{}') as Map<String, dynamic>;
                completer.completeError(Exception('Gagal menambah komentar: ${errorData['error'] ?? errorData['detail'] ?? 'Unknown error'}'));
              } catch (e) {
                completer.completeError(Exception('Gagal menambah komentar: HTTP ${xhr.status}'));
              }
            }
          });
          
          xhr.onError.listen((event) {
            completer.completeError(Exception('Network error saat mengirim komentar'));
          });
          
          final requestBody = jsonEncode({
            'text': text,
            if (rating != null) 'rating': rating,
          });
          
          print('[DEBUG] VideoService.submitComment - Sending XHR request with withCredentials=true');
          xhr.send(requestBody);
          
          return await completer.future;
        } catch (e) {
          print('[DEBUG] VideoService.submitComment - XHR call failed: $e');
          // Fall through to CookieRequest.post() as fallback
        }
      }
      
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

  // ============================================
  // ADMIN CRUD OPERATIONS
  // ============================================

  /// GET /videos/api/sports/ - Get list of sports for dropdown
  /// For now, we'll get sports from existing videos or use hardcoded list
  static Future<List<Map<String, dynamic>>> fetchSports() async {
    // Try to get sports from video list API (extract unique sports)
    try {
      final videos = await fetchVideos();
      final sportsMap = <int, String>{};
      for (var video in videos) {
        // We need to get sport ID from video, but Video model only has sportName
        // For now, use hardcoded list
      }
    } catch (e) {
      print('[DEBUG] VideoService.fetchSports - Error: $e');
    }
    
    // Fallback: return hardcoded sports list
    // TODO: Create proper sports API endpoint or get from video list
    return [
      {'id': 1, 'name': 'Bulu Tangkis'},
      {'id': 2, 'name': 'Renang'},
      {'id': 3, 'name': 'Basket'},
      {'id': 4, 'name': 'Sepak Bola'},
      {'id': 5, 'name': 'Tenis'},
      {'id': 6, 'name': 'Voli'},
    ];
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
    
    // For Flutter Web, use XMLHttpRequest with credentials
    if (kIsWeb) {
      try {
        final xhr = html.HttpRequest();
        final completer = Completer<Video>();
        
        xhr.open('POST', url.toString(), async: true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.withCredentials = true;
        
        xhr.onLoad.listen((event) {
          if (xhr.status == 201 || xhr.status == 200) {
            try {
              final data = jsonDecode(xhr.responseText!) as Map<String, dynamic>;
              completer.complete(Video.fromJson(data));
            } catch (e) {
              completer.completeError(Exception('Gagal memparse response: $e'));
            }
          } else {
            try {
              final errorData = jsonDecode(xhr.responseText ?? '{}') as Map<String, dynamic>;
              completer.completeError(Exception('Gagal membuat video: ${errorData['error'] ?? errorData['detail'] ?? 'Unknown error'}'));
            } catch (e) {
              completer.completeError(Exception('Gagal membuat video: HTTP ${xhr.status}'));
            }
          }
        });
        
        xhr.onError.listen((event) {
          completer.completeError(Exception('Network error saat membuat video'));
        });
        
        final requestBody = jsonEncode({
          'title': title,
          'description': description,
          'sport': sportId,
          'difficulty': difficulty,
          'video_url': videoUrl,
          if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
          if (instructor != null) 'instructor': instructor,
          if (duration != null) 'duration': duration,
          if (tags != null) 'tags': tags,
        });
        
        xhr.send(requestBody);
        return await completer.future;
      } catch (e) {
        throw Exception('Gagal membuat video: $e');
      }
    }
    
    // For mobile, use CookieRequest
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
    if (!request.loggedIn) {
      throw Exception('Anda harus login terlebih dahulu');
    }

    final url = Uri.parse('$baseUrl/videos/api/$videoId/update/');
    
    // For Flutter Web, use XMLHttpRequest with credentials
    if (kIsWeb) {
      try {
        final xhr = html.HttpRequest();
        final completer = Completer<Video>();
        
        xhr.open('POST', url.toString(), async: true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.withCredentials = true;
        
        xhr.onLoad.listen((event) {
          if (xhr.status == 200) {
            try {
              final data = jsonDecode(xhr.responseText!) as Map<String, dynamic>;
              completer.complete(Video.fromJson(data));
            } catch (e) {
              completer.completeError(Exception('Gagal memparse response: $e'));
            }
          } else {
            try {
              final errorData = jsonDecode(xhr.responseText ?? '{}') as Map<String, dynamic>;
              completer.completeError(Exception('Gagal mengupdate video: ${errorData['error'] ?? errorData['detail'] ?? 'Unknown error'}'));
            } catch (e) {
              completer.completeError(Exception('Gagal mengupdate video: HTTP ${xhr.status}'));
            }
          }
        });
        
        xhr.onError.listen((event) {
          completer.completeError(Exception('Network error saat mengupdate video'));
        });
        
        final requestBody = jsonEncode({
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (sportId != null) 'sport': sportId,
          if (difficulty != null) 'difficulty': difficulty,
          if (videoUrl != null) 'video_url': videoUrl,
          if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
          if (instructor != null) 'instructor': instructor,
          if (duration != null) 'duration': duration,
          if (tags != null) 'tags': tags,
        });
        
        xhr.send(requestBody);
        return await completer.future;
      } catch (e) {
        throw Exception('Gagal mengupdate video: $e');
      }
    }
    
    // For mobile, use CookieRequest
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
    
    // For Flutter Web, use XMLHttpRequest with credentials
    if (kIsWeb) {
      try {
        final xhr = html.HttpRequest();
        final completer = Completer<void>();
        
        xhr.open('POST', url.toString(), async: true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.withCredentials = true;
        
        xhr.onLoad.listen((event) {
          if (xhr.status == 200) {
            completer.complete();
          } else {
            try {
              final errorData = jsonDecode(xhr.responseText ?? '{}') as Map<String, dynamic>;
              completer.completeError(Exception('Gagal menghapus video: ${errorData['error'] ?? errorData['detail'] ?? 'Unknown error'}'));
            } catch (e) {
              completer.completeError(Exception('Gagal menghapus video: HTTP ${xhr.status}'));
            }
          }
        });
        
        xhr.onError.listen((event) {
          completer.completeError(Exception('Network error saat menghapus video'));
        });
        
        xhr.send('{}');
        return await completer.future;
      } catch (e) {
        throw Exception('Gagal menghapus video: $e');
      }
    }
    
    // For mobile, use CookieRequest
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


