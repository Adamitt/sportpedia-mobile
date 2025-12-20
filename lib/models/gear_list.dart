// lib/models/gear_list.dart

enum Level {
  BEGINNER,
  INTERMEDIATE,
  ADVANCED,
  UNKNOWN,
}

Level parseLevel(dynamic raw) {
  final value = (raw ?? '').toString().toLowerCase();

  switch (value) {
    case 'beginner':
    case 'pemula':
      return Level.BEGINNER;
    case 'intermediate':
    case 'menengah':
      return Level.INTERMEDIATE;
    case 'advanced':
    case 'lanjutan':
      return Level.ADVANCED;
    default:
      return Level.UNKNOWN;
  }
}

class Gearlist {
  final bool ok;
  final int count;
  final List<Datum> data;

  Gearlist({
    required this.ok,
    required this.count,
    required this.data,
  });

  factory Gearlist.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];

    return Gearlist(
      ok: json['ok'] as bool? ?? true,
      count: json['count'] as int? ?? list.length,
      data: list
          .map((item) => Datum.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }
}

class Datum {
  final String id;
  final String sportId;
  final String sportName;
  final String name;
  final String function;
  final String description;
  final Level level;
  final String levelDisplay;
  final String priceRange;
  final List<String> recommendedBrands;
  final List<String> materials;
  final String careTips;
  final String ecommerceLink;
  final List<String> tags;
  final String image;
  final String? owner;

  Datum({
    required this.id,
    required this.sportId,
    required this.sportName,
    required this.name,
    required this.function,
    required this.description,
    required this.level,
    required this.levelDisplay,
    required this.priceRange,
    required this.recommendedBrands,
    required this.materials,
    required this.careTips,
    required this.ecommerceLink,
    required this.tags,
    required this.image,
    required this.owner,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    List<String> _stringList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      // kalau backend tiba-tiba kirim string "a, b, c"
      return raw
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Datum(
      id: json['id']?.toString() ?? '',
      sportId: json['sport_id']?.toString() ?? '',
      sportName: json['sport_name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      function: json['function']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      level: parseLevel(json['level']),
      levelDisplay: json['level_display']?.toString() ?? '',
      priceRange: json['price_range']?.toString() ?? '',
      recommendedBrands: _stringList(json['recommended_brands']),
      materials: _stringList(json['materials']),
      careTips: json['care_tips']?.toString() ?? '',
      ecommerceLink: json['ecommerce_link']?.toString() ?? '',
      tags: _stringList(json['tags']),
      image: json['image']?.toString() ?? '',
      owner: json['owner']?.toString(),
    );
  }
}
