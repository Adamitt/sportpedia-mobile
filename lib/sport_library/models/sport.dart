import 'dart:convert';

List<Sport> sportFromJson(String str) =>
    List<Sport>.from(json.decode(str).map((x) => Sport.fromJson(x)));

String sportToJson(List<Sport> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

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
  String image;
  bool isSaved;

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
    required this.image,
    this.isSaved = false,
  });

  factory Sport.fromJson(Map<String, dynamic> json) => Sport(
        id: json["id"],
        name: json["name"],
        category: json["category"],
        difficulty: json["difficulty"],
        description: json["description"],
        history: json["history"],
        rules: List<String>.from(json["rules"].map((x) => x)),
        techniques: List<String>.from(json["techniques"].map((x) => x)),
        benefits: List<String>.from(json["benefits"].map((x) => x)),
        popularCountries:
            List<String>.from(json["popular_countries"].map((x) => x)),
        tags: List<String>.from(json["tags"].map((x) => x)),
        image: json["image"] ?? "",
        isSaved: json["is_saved"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category,
        "difficulty": difficulty,
        "description": description,
        "history": history,
        "rules": List<dynamic>.from(rules.map((x) => x)),
        "techniques": List<dynamic>.from(techniques.map((x) => x)),
        "benefits": List<dynamic>.from(benefits.map((x) => x)),
        "popular_countries": List<dynamic>.from(popularCountries.map((x) => x)),
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "image": image,
        "is_saved": isSaved,
      };
}
