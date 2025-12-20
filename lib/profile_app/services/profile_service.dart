// Service untuk API calls terkait Profil & Perjalanan
// Mengimplementasikan pemanggilan asinkronus ke web service Django

import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/user_profile.dart';
import '../models/activity_history.dart';

class ProfileService {
  // ============================================================
  // BASE URL CONFIGURATION
  // ============================================================
  // Untuk development:
  //   - Android Emulator: https://ainur-fadhil-sportpedia.pbp.cs.ui.ac.id/
  //   - iOS Simulator: http://localhost:8000
  //   - Chrome/Web: http://localhost:8000
  //   - Device fisik: http://IP_KOMPUTER:8000
  // Untuk production:
  //   - https://ainur-fadhil-sportpedia.pbp.cs.ui.ac.id
  // ============================================================

  // Untuk Chrome/Web: http://localhost:8000
  // Untuk Android Emulator: https://ainur-fadhil-sportpedia.pbp.cs.ui.ac.id/
  // Untuk Production: https://ainur-fadhil-sportpedia.pbp.cs.ui.ac.id
  static const String baseUrl = 'http://localhost:8000';

  // ============================================================
  // PROFIL USER - READ
  // ============================================================

  /// Mengambil profil user yang sedang login
  static Future<UserProfile?> getProfile(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/profile/api/profile/');

      if (response != null && response['status'] == true) {
        return UserProfile.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // ============================================================
  // PROFIL USER - UPDATE
  // ============================================================

  /// Update profil user
  static Future<Map<String, dynamic>> updateProfile(
    CookieRequest request,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl/profile/api/profile/update/',
        jsonEncode(profileData),
      );

      return {
        'success': response['status'] == true,
        'message': response['message'] ?? 'Profile updated',
      };
    } catch (e) {
      print('Error updating profile: $e');
      return {'success': false, 'message': 'Gagal mengupdate profil: $e'};
    }
  }

  // ============================================================
  // RIWAYAT AKTIVITAS
  // ============================================================

  /// Mengambil riwayat aktivitas user
  static Future<List<ActivityHistory>> getActivityHistory(
    CookieRequest request, {
    int? limit,
  }) async {
    try {
      final response = await request.get('$baseUrl/profile/api/activity/');

      if (response != null &&
          response['status'] == true &&
          response['data'] != null) {
        List<ActivityHistory> activities = List<ActivityHistory>.from(
          response['data'].map((item) => ActivityHistory.fromJson(item)),
        );

        // Apply limit if specified
        if (limit != null && activities.length > limit) {
          activities = activities.take(limit).toList();
        }

        return activities;
      }
      return [];
    } catch (e) {
      print('Error fetching activity history: $e');
      return [];
    }
  }

  /// Mencatat aktivitas baru
  static Future<bool> logActivity(
    CookieRequest request, {
    required String actionType,
    required String description,
  }) async {
    try {
      final response = await request.postJson(
        '$baseUrl/profile/api/activity/log/',
        jsonEncode({'action_type': actionType, 'description': description}),
      );

      return response['status'] == true;
    } catch (e) {
      print('Error logging activity: $e');
      return false;
    }
  }

  /// Hapus semua riwayat aktivitas
  static Future<Map<String, dynamic>> clearActivityHistory(
    CookieRequest request,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl/profile/api/activity/clear/',
        jsonEncode({}),
      );

      return {
        'success': response['status'] == true,
        'message': response['message'] ?? 'Activity cleared',
      };
    } catch (e) {
      print('Error clearing activity: $e');
      return {'success': false, 'message': 'Gagal menghapus riwayat: $e'};
    }
  }

  // ============================================================
  // PENGATURAN AKUN
  // ============================================================

  /// Update password
  static Future<Map<String, dynamic>> updatePassword(
    CookieRequest request, {
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await request.postJson(
        '$baseUrl/profile/api/change-password/',
        jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      return {
        'success': response['status'] == true,
        'message': response['message'] ?? 'Password updated',
      };
    } catch (e) {
      print('Error updating password: $e');
      return {'success': false, 'message': 'Gagal mengupdate password: $e'};
    }
  }

  /// Update email
  static Future<Map<String, dynamic>> updateEmail(
    CookieRequest request, {
    required String newEmail,
    required String password,
  }) async {
    try {
      final response = await request.postJson(
        '$baseUrl/profile/api/change-email/',
        jsonEncode({'email': newEmail, 'password': password}),
      );

      return {
        'success': response['status'] == true,
        'message': response['message'] ?? 'Email updated',
      };
    } catch (e) {
      print('Error updating email: $e');
      return {'success': false, 'message': 'Gagal mengupdate email: $e'};
    }
  }

  /// Hapus akun
  static Future<Map<String, dynamic>> deleteAccount(
    CookieRequest request, {
    required String password,
  }) async {
    try {
      final response = await request.postJson(
        '$baseUrl/profile/api/delete-account/',
        jsonEncode({'password': password}),
      );

      return {
        'success': response['status'] == true,
        'message': response['message'] ?? 'Account deleted',
      };
    } catch (e) {
      print('Error deleting account: $e');
      return {'success': false, 'message': 'Gagal menghapus akun: $e'};
    }
  }

  // ============================================================
  // STATISTIK PROFIL
  // ============================================================

  /// Mengambil statistik user
  static Future<Map<String, dynamic>> getProfileStats(
    CookieRequest request,
  ) async {
    try {
      final response = await request.get('$baseUrl/profile/api/stats/');

      if (response != null && response['status'] == true) {
        final data = response['data'];
        return {
          'success': true,
          'total_activities': data['total_activities'] ?? 0,
          'activity_breakdown': data['activity_breakdown'] ?? {},
          'recent_activities': data['recent_activities'] ?? [],
          'member_since': data['member_since'],
          'days_as_member': data['days_as_member'] ?? 0,
          // Mapped stats for UI
          'sports_viewed': data['activity_breakdown']?['MODULE_ACCESS'] ?? 0,
          'videos_watched': data['activity_breakdown']?['VIDEO_VIEW'] ?? 0,
          'forum_posts': data['activity_breakdown']?['FORUM_POST'] ?? 0,
          'bookmarks': 0, // Add bookmark tracking if needed
        };
      }
      return {'success': false};
    } catch (e) {
      print('Error fetching profile stats: $e');
      return {'success': false};
    }
  }
}
