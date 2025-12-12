// Model untuk Activity History (Riwayat Aktivitas)
// Sesuai dengan response dari Django API /profile/api/activity/

import 'dart:convert';

/// Parse list ActivityHistory dari API response
List<ActivityHistory> activityHistoryFromJson(String str) {
  final json = jsonDecode(str);
  // API returns {status: true, data: [...]}
  if (json['status'] == true && json['data'] != null) {
    return List<ActivityHistory>.from(
      json['data'].map((x) => ActivityHistory.fromJson(x)),
    );
  }
  return [];
}

/// Convert list ActivityHistory ke JSON string
String activityHistoryToJson(List<ActivityHistory> data) =>
    jsonEncode(List<dynamic>.from(data.map((x) => x.toJson())));

class ActivityHistory {
  final int id;
  final String actionType;
  final String actionDisplay;
  final String description;
  final DateTime timestamp;

  ActivityHistory({
    required this.id,
    required this.actionType,
    required this.actionDisplay,
    required this.description,
    required this.timestamp,
  });

  /// Factory constructor untuk parsing dari Django API
  factory ActivityHistory.fromJson(Map<String, dynamic> json) =>
      ActivityHistory(
        id: json["id"],
        actionType: json["action_type"] ?? "",
        actionDisplay: json["action_display"] ?? "",
        description: json["description"] ?? "",
        timestamp: DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "action_type": actionType,
    "action_display": actionDisplay,
    "description": description,
    "timestamp": timestamp.toIso8601String(),
  };

  /// Helper untuk mendapatkan icon berdasarkan action type
  String get activityIcon {
    switch (actionType) {
      case 'MODULE_ACCESS':
        return '📱';
      case 'VIDEO_VIEW':
        return '🎬';
      case 'FORUM_POST':
        return '💬';
      case 'TESTIMONIAL_SUBMIT':
        return '⭐';
      case 'ADMIN_CREATE':
        return '➕';
      case 'ADMIN_UPDATE':
        return '✏️';
      case 'ADMIN_DELETE':
        return '🗑️';
      default:
        return '📌';
    }
  }

  /// Helper untuk title (menggunakan action_display atau description)
  String get title => actionDisplay.isNotEmpty ? actionDisplay : description;

  /// Helper untuk format waktu relatif
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Helper untuk format tanggal lengkap
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year}, '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
