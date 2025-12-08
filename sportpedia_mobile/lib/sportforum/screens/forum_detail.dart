import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/sportforum/models/forum_entry.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart' as pbp;

class ForumDetailPage extends StatefulWidget {
  final ForumEntry forum;
  final pbp.CookieRequest request;

  const ForumDetailPage({super.key, required this.forum, required this.request});

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateIso(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      return _formatDate(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  Future<Map<String, dynamic>> _fetchDetail(pbp.CookieRequest request) async {
    final url = 'http://localhost:8000/forum/post/json/${widget.forum.id}/';
    final resp = await request.get(url);
    return Map<String, dynamic>.from(resp);
  }

  Future<void> _toggleLike(pbp.CookieRequest request) async {
    final url = 'http://localhost:8000/forum/post/${widget.forum.id}/like';
    try {
      await request.post(url, {});
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final Map<String, dynamic> jd = Map<String, dynamic>.from(request.jsonData);
    final String? currentUsername = jd['username']?.toString();
    final bool isMine = currentUsername != null &&
      widget.forum.author.toLowerCase() == currentUsername.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchDetail(request),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final detail = snapshot.data!;
          final int likes = (detail['likes'] ?? 0) as int;
          final bool userHasLiked = detail['user_has_liked'] == true;
          final List<dynamic> replies = (detail['replies'] as List?) ?? const [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (replies.length > 20)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      margin: const EdgeInsets.only(bottom: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const Text(
                        'Highlight',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),

                  // Title
                  Text(
                    widget.forum.title,
                    style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Category, Date, Likes
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade100,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          widget.forum.sport.toUpperCase(),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(widget.forum.datePosted),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _toggleLike(request),
                        child: Row(
                          children: [
                            Icon(
                              userHasLiked ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: userHasLiked ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text('$likes', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Owner info
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        isMine ? 'Owner: You' : 'Owner: ${widget.forum.author}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Full content
                  Text(
                    widget.forum.content,
                    style: const TextStyle(fontSize: 16.0, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 24),

                  // Replies section
                  const Text(
                    'Replies',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (replies.isEmpty)
                    const Text('No replies yet.', style: TextStyle(color: Colors.grey))
                  else
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: replies.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final r = replies[index] as Map<String, dynamic>;
                        final user = (r['user'] ?? 'Unknown').toString();
                        final comment = (r['comment'] ?? '').toString();
                        final date = _formatDateIso(r['date']?.toString());
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.indigo,
                            child: Text(user.isNotEmpty ? user[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (date.isNotEmpty)
                                Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(comment),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}