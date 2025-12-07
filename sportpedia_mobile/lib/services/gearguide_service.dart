// lib/services/gearguide_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:sportpedia_mobile/models/gear_list.dart';

class GearGuideService {
  // ganti host kalau kamu jalanin server di alamat lain
  static String get baseUrl => kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

  /// Ambil list gear (GET /gearguide/json/)
  static Future<List<Datum>> fetchGears() async {
    final url = Uri.parse('$baseUrl/gearguide/json/');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data gear (status: ${response.statusCode})');
    }

    final Map<String, dynamic> body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    final gearlist = Gearlist.fromJson(body);
    return gearlist.data;
  }

  /// Submit gear (POST form-encoded ke /gearguide/flutter/add/)
  /// Mengembalikan Map: {'success': true, 'data': ...} atau {'success': false, 'message': ...}
  static Future<Map<String, dynamic>> submitGear({
    required String name,
    required String sportId,
    String function = '',
    String description = '',
    String image = '',
    String priceRange = '',
    String ecommerceLink = '',
    String level = 'beginner',
    List<String>? recommendedBrands,
    List<String>? materials,
    String careTips = '',
    List<String>? tags,
  }) async {
    final url = Uri.parse('$baseUrl/gearguide/flutter/add/');

    // convert lists -> comma separated string for Django view that uses request.POST.get(...)
    final body = <String, String>{
      'name': name,
      'sport': sportId,
      'function': function,
      'description': description,
      'image': image,
      'price_range': priceRange,
      'ecommerce_link': ecommerceLink,
      'level': level,
      'recommended_brands': (recommendedBrands ?? []).join(', '),
      'materials': (materials ?? []).join(', '),
      'care_tips': careTips,
      'tags': (tags ?? []).join(', '),
    };

    try {
      final resp = await http.post(url, body: body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        // coba parse JSON, kalau bukan JSON kembalikan raw
        try {
          final decoded = jsonDecode(utf8.decode(resp.bodyBytes));
          return {'success': true, 'data': decoded};
        } catch (_) {
          return {'success': true, 'raw': resp.body};
        }
      } else {
        String message = resp.body;
        try {
          final parsed = jsonDecode(utf8.decode(resp.bodyBytes));
          message = parsed.toString();
        } catch (_) {}
        return {'success': false, 'status': resp.statusCode, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
