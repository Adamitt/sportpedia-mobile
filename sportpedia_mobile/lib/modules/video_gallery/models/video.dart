class Video {
  final int id;
  final String title;
  final String description;
  final String thumbnail; // field "thumbnail" dari JSON
  final String url; // link YouTube
  final String difficulty; // "Pemula", "Menengah", "Lanjutan"
  final String sportName; // "Bulu Tangkis", "Renang", dll.
  final String duration; // misal: "04:21"
  final double rating;
  final int views;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.url,
    required this.difficulty,
    required this.sportName,
    required this.duration,
    required this.rating,
    required this.views,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      url: json['url'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      sportName: json['sport_name'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      views: (json['views'] as num?)?.toInt() ?? 0,
    );
  }
}


