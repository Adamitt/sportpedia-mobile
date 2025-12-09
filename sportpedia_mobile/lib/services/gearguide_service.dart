// lib/services/gearguide_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Menambahkan import untuk Future

import 'package:sportpedia_mobile/models/gear_list.dart';

class GearGuideService {
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

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

  static Future<List<Map<String, String>>> getSports() async {
    final url = Uri.parse('$baseUrl/gearguide/flutter/sports/');
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat daftar olahraga (status: ${response.statusCode})');
    }

    final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
    
    if (body['ok'] == false) {
       throw Exception('Server error saat fetch sports: ${body['error']}');
    }

    final List<dynamic> jsonList = body['data'] as List<dynamic>? ?? []; 

    return jsonList.map((sport) {
      if (sport is Map<String, dynamic>) {
          return {
            'id': sport['id']?.toString() ?? '', 
            'name': sport['name']?.toString() ?? 'Unknown Sport',
          };
      }
      // Handle jika item di dalam list bukan Map yang diharapkan
      return {'id': '', 'name': 'Invalid Data'};
    }).toList();
  }

  static Future<Map<String, dynamic>> submitGear(
  BuildContext context, {
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
  final request = context.read<CookieRequest>();

  final body = {
    'name': name,
    'sport': sportId,
    'function': function,
    'description': description,
    'image': image,
    'price_range': priceRange,
    'ecommerce_link': ecommerceLink,
    'level': level,
    // ⬇️ KIRIM STRING, BUKAN LIST
    'recommended_brands': (recommendedBrands ?? []).join(','),
    'materials': (materials ?? []).join(','),
    'care_tips': careTips,
    'tags': (tags ?? []).join(','),
  };

  final url = '$baseUrl/gearguide/flutter/gears/add/';
  final response = await request.post(url, body);

  return Map<String, dynamic>.from(response);
}

  static Future<Map<String, dynamic>> editGear(
    BuildContext context,
    String id, {
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
    final request = context.read<CookieRequest>();

    final body = {
      'name': name,
      'sport': sportId,
      'function': function,
      'description': description,
      'image': image,
      'price_range': priceRange,
      'ecommerce_link': ecommerceLink,
      'level': level,
      'recommended_brands': (recommendedBrands ?? []).join(','),
      'materials': (materials ?? []).join(','),
      'tags': (tags ?? []).join(','),
      'care_tips': careTips,
    };

    final url = '$baseUrl/gearguide/flutter/gears/$id/edit/';
    final response = await request.post(url, body);
    return Map<String, dynamic>.from(response);
  }


    static Future<Map<String, dynamic>> deleteGear(
    BuildContext context,
    String id,
  ) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/gearguide/flutter/gears/$id/delete/';

    final response = await request.post(url, {}); // pakai POST, bukan http.delete
    return Map<String, dynamic>.from(response);
  }

}