/// Model untuk komentar video
class Comment {
  final int id;
  final String user;
  final String text;
  final int? rating;
  final int helpfulCount;
  final String createdAt;

  Comment({
    required this.id,
    required this.user,
    required this.text,
    this.rating,
    required this.helpfulCount,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      user: json['user'] as String? ?? 'Anonymous',
      text: json['text'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt(),
      helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 
                   (json['helpfulCount'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String? ?? 
                 json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'text': text,
      'rating': rating,
      'helpful_count': helpfulCount,
      'created_at': createdAt,
    };
  }
}

