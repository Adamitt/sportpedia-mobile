class Testimonial {
  final int id;
  final String title;
  final String text;
  final String user;
  final String category;
  final String imageUrl;
  final String createdAt;
  final bool isOwner;

  Testimonial({
    required this.id,
    required this.title,
    required this.text,
    required this.user,
    required this.category,
    required this.imageUrl,
    required this.createdAt,
    required this.isOwner,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id'],
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      user: json['user'] ?? 'Guest',
      category: json['category'] ?? 'library',
      imageUrl: json['image_url'] ?? '',
      createdAt: json['created_at'] ?? '',
      isOwner: json['is_owner'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'text': text,
      'category': category,
      'image_url': imageUrl,
    };
  }
}

