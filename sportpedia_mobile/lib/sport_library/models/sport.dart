import 'dart:convert';

List<Sport> sportFromJson(String str) => List<Sport>.from(json.decode(str).map((x) => Sport.fromJson(x)));

String sportToJson(List<Sport> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Sport {
    int id;
    String name;
    String category;
    String difficulty;
    String description;
    String history;
    List<String> rules;
    List<String> techniques;
    List<String> benefits;
    List<String> popularCountries;
    List<String> tags;
    // Image diabaikan dulu untuk simplicity, atau bisa kirim URL string
    
    Sport({
        required this.id,
        required this.name,
        required this.category,
        required this.difficulty,
        required this.description,
        required this.history,
        required this.rules,
        required this.techniques,
        required this.benefits,
        required this.popularCountries,
        required this.tags,
    });

    factory Sport.fromJson(Map<String, dynamic> json) => Sport(
        id: json["id"],
        name: json["name"],
        category: json["category"],
        difficulty: json["difficulty"],
        description: json["description"],
        history: json["history"],
        // Handle JSONField dari Django yang mungkin berupa string atau list
        rules: List<String>.from(json["rules"] is String ? jsonDecode(json["rules"]) : json["rules"] ?? []),
        techniques: List<String>.from(json["techniques"] is String ? jsonDecode(json["techniques"]) : json["techniques"] ?? []),
        benefits: List<String>.from(json["benefits"] is String ? jsonDecode(json["benefits"]) : json["benefits"] ?? []),
        popularCountries: List<String>.from(json["popular_countries"] is String ? jsonDecode(json["popular_countries"]) : json["popular_countries"] ?? []),
        tags: List<String>.from(json["tags"] is String ? jsonDecode(json["tags"]) : json["tags"] ?? []),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "category": category,
        "difficulty": difficulty,
        "description": description,
        "history": history,
        "rules": rules,
        "techniques": techniques,
        "benefits": benefits,
        "popular_countries": popularCountries,
        "tags": tags,
    };
}