class PopularCategory {
  final String title;
  final String url;
  final String image;
  final String category;
  final int views;
  final String? excerpt;

  PopularCategory({
    required this.title,
    required this.url,
    required this.image,
    required this.category,
    required this.views,
    this.excerpt,
  });

  factory PopularCategory.fromJson(Map<String, dynamic> json) {
    return PopularCategory(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      views: json['views'] ?? 0,
      excerpt: json['excerpt'],
    );
  }
}

