import 'package:pbp_django_auth/pbp_django_auth.dart' as pbp;
import 'package:sportpedia_mobile/config/api_config.dart';

class ForumService {
  static String get _base => ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> fetchDetail(
    pbp.CookieRequest request,
    String postId,
  ) async {
    final url = '$_base/forum/post/json/$postId/';
    final resp = await request.get(url);
    return Map<String, dynamic>.from(resp);
  }

  static Future<void> toggleLike(
    pbp.CookieRequest request,
    String postId,
  ) async {
    final url = '$_base/forum/post/$postId/like-flutter';
    await request.post(url, {});
  }

  static Future<void> postReply(
    pbp.CookieRequest request,
    String postId,
    String comment,
  ) async {
    // Django view handles POST to /forum/post/{id}/ to add a reply
    final url = '$_base/forum/post/$postId/reply-flutter';
    await request.post(url, {
      'comment': comment,
    });
  }

  static Future<void> deletePost(
    pbp.CookieRequest request,
    String postId,
  ) async {
    final url = '$_base/forum/post/$postId/delete-flutter';
    await request.post(url, {});
  }

  static Future<void> updatePost(
    pbp.CookieRequest request,
    String postId,
    Map<String, dynamic> payload,
  ) async {
    // Matches Django's edit_post view that expects form fields
    final url = '$_base/forum/post/$postId/edit-flutter';
    await request.post(url, payload);
  }
}
