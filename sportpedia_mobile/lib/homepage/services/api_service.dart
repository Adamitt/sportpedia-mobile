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
      final uri = Uri.parse('$baseUrl/api/testimonials/$id/delete/');

      final response = await http.post(uri);

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
}

