// To parse this JSON data, do
//
//     final forumEntry = forumEntryFromJson(jsonString);

import 'dart:convert';

List<ForumEntry> forumEntryFromJson(String str) => List<ForumEntry>.from(json.decode(str).map((x) => ForumEntry.fromJson(x)));

String forumEntryToJson(List<ForumEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ForumEntry {
    String id;
    String sport;
    String sportSlug;
    String title;
    String author;
    String content;
    int likes;
    int views;
    DateTime datePosted;
    List<String> tags;
    int repliesCount;
    Source source;

    ForumEntry({
        required this.id,
        required this.sport,
        required this.sportSlug,
        required this.title,
        required this.author,
        required this.content,
        required this.likes,
        required this.views,
        required this.datePosted,
        required this.tags,
        required this.repliesCount,
        required this.source,
    });

    factory ForumEntry.fromJson(Map<String, dynamic> json) => ForumEntry(
        id: json["id"],
        sport: json["sport"],
        sportSlug: json["sport_slug"],
        title: json["title"],
        author: json["author"],
        content: json["content"],
        likes: json["likes"],
        views: json["views"],
        datePosted: DateTime.parse(json["date_posted"]),
        tags: List<String>.from(json["tags"].map((x) => x)),
        repliesCount: json["replies_count"],
        source: sourceValues.map[json["source"]]!,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "sport": sport,
        "sport_slug": sportSlug,
        "title": title,
        "author": author,
        "content": content,
        "likes": likes,
        "views": views,
        "date_posted": datePosted.toIso8601String(),
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "replies_count": repliesCount,
        "source": sourceValues.reverse[source],
    };
}

enum Source {
    DATABASE
}

final sourceValues = EnumValues({
    "database": Source.DATABASE
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
