import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/testimonial.dart';
import '../models/popular_category.dart';
import '../../config/api_config.dart';

class HomepageApiService {
  static const String baseUrl = ApiConfig.baseUrl;

  // ============================================
  // TESTIMONIALS API
  // ============================================

  /// GET: List testimonials (using CookieRequest to send cookies for is_owner detection)
  static Future<List<Testimonial>> getTestimonials({
    required dynamic request, // CookieRequest
    String category = 'all',
    int limit = 30,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/testimonials/')
          .replace(queryParameters: {
        if (category != 'all') 'category': category,
        'limit': limit.toString(),
      });

      // Use CookieRequest.get to send cookies so Django can determine is_owner
      final response = await request.get(uri.toString());

      if (response is Map<String, dynamic>) {
        final items = response['items'] as List;
        return items.map((item) => Testimonial.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load testimonials: Invalid response format');
      }
    } catch (e) {
      throw Exception('Error fetching testimonials: $e');
    }
  }

  /// POST: Create testimonial (using CookieRequest for authentication)
  static Future<Testimonial> createTestimonial({
    required String text,
    required dynamic request, // CookieRequest
    String category = 'library',
    String? imageUrl,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/testimonials/create/');
      final payload = <String, dynamic>{
        'text': text,
        'category': category,
        if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      };

      final response = await request.post(
        uri.toString(),
        payload,
      );

      // Check if response is a Map (JSON) or String (HTML error page)
      if (response is Map<String, dynamic>) {
        if (response['item'] != null) {
          return Testimonial.fromJson(response['item']);
        } else {
          throw Exception(response['error'] ?? 'Failed to create testimonial');
        }
      } else {
        // If response is not a Map, it might be an HTML error page
        throw Exception('Server returned invalid response. Please check if you are logged in and try again.');
      }
    } catch (e) {
      // Provide more helpful error message
      String errorMsg = e.toString();
      if (errorMsg.contains('FormatException') || errorMsg.contains('<!DOCTYPE')) {
        errorMsg = 'Server error: Please make sure you are logged in and try again.';
      }
      throw Exception('Error creating testimonial: $errorMsg');
    }
  }

  /// POST: Update testimonial (using CookieRequest for authentication)
  static Future<Testimonial> updateTestimonial({
    required int id,
    required dynamic request, // CookieRequest
    String? text,
    String? category,
    String? imageUrl,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/testimonials/$id/update/');
      final payload = <String, dynamic>{};
      if (text != null) payload['text'] = text;
      if (category != null) payload['category'] = category;
      if (imageUrl != null) payload['image_url'] = imageUrl;

      final response = await request.post(
        uri.toString(),
        payload,
      );

      // Check if response is a Map (JSON) or String (HTML error page)
      if (response is Map<String, dynamic>) {
        if (response['item'] != null || response['ok'] == true || response['status'] == 'success') {
          return Testimonial.fromJson(response['item']);
        } else {
          throw Exception(response['error'] ?? 'Failed to update testimonial');
        }
      } else {
        throw Exception('Server returned invalid response. Please check if you are logged in and try again.');
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('FormatException') || errorMsg.contains('<!DOCTYPE')) {
        errorMsg = 'Server error: Please make sure you are logged in and try again.';
      }
      throw Exception('Error updating testimonial: $errorMsg');
    }
  }

  /// POST: Delete testimonial (using CookieRequest for authentication)
  static Future<bool> deleteTestimonial({
    required int id,
    required dynamic request, // CookieRequest
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/testimonials/$id/delete/');

      final response = await request.post(
        uri.toString(),
        {},
      );

      // Check if response is a Map (JSON) or String (HTML error page)
      if (response is Map<String, dynamic>) {
        // Django returns {"status": "success"} or {"ok": true}
        if (response['status'] == 'success' || response['ok'] == true || response.containsKey('status')) {
          return true;
        } else {
          throw Exception(response['error'] ?? 'Failed to delete testimonial');
        }
      } else {
        throw Exception('Server returned invalid response. Please check if you are logged in and try again.');
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('FormatException') || errorMsg.contains('<!DOCTYPE')) {
        errorMsg = 'Server error: Please make sure you are logged in and try again.';
      }
      throw Exception('Error deleting testimonial: $errorMsg');
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
  /// 
  /// Endpoint: /api/search/
  /// Query parameter: 'q' (query string)
  /// Response structure (sesuai Django api_search):
  /// {
  ///   "query": string,
  ///   "gear_results": List<Map>,
  ///   "sport_results": List<Map>
  /// }
  /// 
  /// Django akan:
  /// 1. Normalize query terms (split by non-word chars, lowercase, filter short terms)
  /// 2. Search in Gear: name, description, function, sport.name
  /// 3. Search in Sport: name, description, history
  /// 4. Return matching results
  static Future<Map<String, dynamic>> search({
    required String query,
  }) async {
    try {
      // Endpoint sesuai Django: landingpage/urls.py path("api/search/", ...)
      final uri = Uri.parse('$baseUrl/api/search/')
          .replace(queryParameters: {
        'q': query, // Django menerima 'q', 'query', atau 'search' - kita pakai 'q'
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        
        // Response structure harus sesuai dengan Django api_search response
        // Django returns: {"query": str, "gear_results": [...], "sport_results": [...]}
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

