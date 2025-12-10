/// Model untuk komentar video
class Comment {
  final int id;
  final String user;
  final String text;
  final int? rating;
  final int helpfulCount;
  final String createdAt;
  final List<Comment> replies;
  final int? parentId;

  Comment({
    required this.id,
    required this.user,
    required this.text,
    this.rating,
    required this.helpfulCount,
    required this.createdAt,
    this.replies = const [],
    this.parentId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // Parse replies if they exist
    List<Comment> repliesList = [];
    if (json['replies'] != null && json['replies'] is List) {
      repliesList = (json['replies'] as List)
          .map((replyJson) => Comment.fromJson(replyJson as Map<String, dynamic>))
          .toList();
    }
    
    return Comment(
      id: json['id'] as int,
      user: json['user'] as String? ?? 'Anonymous',
      text: json['text'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt(),
      helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 
                   (json['helpfulCount'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String? ?? 
                 json['createdAt'] as String? ?? '',
      replies: repliesList,
      parentId: (json['parent_id'] as num?)?.toInt(),
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
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'parent_id': parentId,
    };
  }
  
  bool get isReply => parentId != null;
}

