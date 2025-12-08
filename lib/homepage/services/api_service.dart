import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/testimonial.dart';
import '../models/popular_category.dart';
import '../../config/api_config.dart';

class HomepageApiService {
  static const String baseUrl = ApiConfig.baseUrl;
  static String? _csrfToken;
  static final http.Client _client = http.Client();

  /// GET: Ambil CSRF token dari Django
  static Future<String> _getCsrfToken() async {
    if (_csrfToken != null) return _csrfToken!;
    
    try {
      final uri = Uri.parse('$baseUrl/api/csrf-token/');
      final response = await _client.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _csrfToken = data['csrfToken'] as String;
        return _csrfToken!;
      }
    } catch (e) {
      print('Error getting CSRF token: $e');
    }
    
    return '';
  }

  // ============================================
  // TESTIMONIALS API
  // ============================================

  /// GET: List testimonials
  static Future<List<Testimonial>> getTestimonials({
    String category = 'all',
    int limit = 30,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/testimonials/')
          .replace(queryParameters: {
        if (category != 'all') 'category': category,
        'limit': limit.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        return items.map((item) => Testimonial.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load testimonials: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching testimonials: $e');
    }
  }

  /// POST: Create testimonial
  static Future<Testimonial> createTestimonial({
    required String text,
    String? title,
    String category = 'library',
    String? imageUrl,
  }) async {
    try {
      // Get CSRF token dulu
      final csrfToken = await _getCsrfToken();
      
      final uri = Uri.parse('$baseUrl/api/testimonials/create/');
      final payload = json.encode({
        'text': text,
        if (title != null && title.isNotEmpty) 'title': title,
        'category': category,
        if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      });

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (csrfToken.isNotEmpty) 'X-CSRFToken': csrfToken,
        },
        body: payload,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Testimonial.fromJson(data['item']);
      } else {
        final error = response.body;
        throw Exception('Failed to create testimonial: $error');
      }
    } catch (e) {
      throw Exception('Error creating testimonial: $e');
    }
  }

  /// POST: Update testimonial
  static Future<Testimonial> updateTestimonial({
    required int id,
    String? title,
    String? text,
    String? category,
    String? imageUrl,
  }) async {
    try {
      // Get CSRF token dulu
      final csrfToken = await _getCsrfToken();
      
      final uri = Uri.parse('$baseUrl/api/testimonials/$id/update/');
      final payload = <String, dynamic>{};
      if (title != null) payload['title'] = title;
      if (text != null) payload['text'] = text;
      if (category != null) payload['category'] = category;
      if (imageUrl != null) payload['image_url'] = imageUrl;

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (csrfToken.isNotEmpty) 'X-CSRFToken': csrfToken,
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Testimonial.fromJson(data['item']);
      } else {
        final error = response.body;
        throw Exception('Failed to update testimonial: $error');
      }
    } catch (e) {
      throw Exception('Error updating testimonial: $e');
    }
  }

  /// POST: Delete testimonial
  static Future<bool> deleteTestimonial(int id) async {
    try {
      // Get CSRF token dulu
      final csrfToken = await _getCsrfToken();
      
      final uri = Uri.parse('$baseUrl/api/testimonials/$id/delete/');

      final response = await http.post(
        uri,
        headers: {
          if (csrfToken.isNotEmpty) 'X-CSRFToken': csrfToken,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = response.body;
        throw Exception('Failed to delete testimonial: $error');
      }
    } catch (e) {
      throw Exception('Error deleting testimonial: $e');
    }
  }

  // ============================================
  // POPULAR CATEGORIES API
  // ============================================

  /// GET: List popular categories
  static Future<List<PopularCategory>> getPopularCategories({
    int limit = 3,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/popular-categories/')
          .replace(queryParameters: {
        'limit': limit.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        return items.map((item) => PopularCategory.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load popular categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching popular categories: $e');
    }
  }

  // ============================================
  // SEARCH API
  // ============================================

  /// GET: Search Gear dan Sport (sesuai logic Django)
  static Future<Map<String, dynamic>> search({
    required String query,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/search/')
          .replace(queryParameters: {
        'q': query,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'query': data['query'] ?? '',
          'gear_results': (data['gear_results'] as List?) ?? [],
          'sport_results': (data['sport_results'] as List?) ?? [],
        };
      } else {
        throw Exception(
            'Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching: $e');
    }
  }
}

