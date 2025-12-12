import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/sportforum/models/forum_entry.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart' as pbp;
import 'package:sportpedia_mobile/sportforum/screens/forum_edit_form.dart';

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

    final String displayAuthor = widget.forum.author.isNotEmpty
        ? widget.forum.author
        : 'Unknown';
    final String avatarInitial = displayAuthor[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          if (isMine)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    // Navigate to edit form
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ForumEditPage(
                          forum: widget.forum,
                          request: widget.request,
                        ),
                      ),
                    );
                    if (!mounted) return;
                    setState(() {});
                    break;
                  case 'delete':
                    try {
                      await widget.request.post(
                        'http://localhost:8000/forum/post/${widget.forum.id}/delete-flutter',
                        {},
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post deleted')),
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Delete failed: $e')),
                      );
                    }
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
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

                  // Chips row – show sport, highlight and tags on top
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      // Sport chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          widget.forum.sport.toUpperCase(),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      // Highlight if many replies
                      if ((detail['replies'] as List?)?.length != null && ((detail['replies'] as List?)?.length ?? 0) > 20)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE69A),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'HIGHLIGHT',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                          ),
                        ),
                      // Tags
                      ...((widget.forum.tags ?? const <String>[]) as List<String>).map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            '#$t',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF4B5563)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Header: avatar + title + meta + like
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.blue,
                        child: Text(
                          avatarInitial,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.forum.title,
                              style: const TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  displayAuthor,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text('·', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDate(widget.forum.datePosted),
                                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Align like to author/date baseline with a small top padding
                      
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  const Divider(height: 2, thickness: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 12),

                  // Full content
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      widget.forum.content,
                      style: const TextStyle(fontSize: 16.0, height: 1.6),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  
                 

                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Colors.transparent,
                          shape: const StadiumBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _toggleLike(request),
                            customBorder: const StadiumBorder(),
                            hoverColor: Colors.black12,
                            splashColor: Colors.black12,
                            highlightColor: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    userHasLiked ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                    color: userHasLiked ? Colors.red : Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$likes',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                              
                  // Replies section
                  const Text(
                    'Replies',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Replies list: use Column and a constrained ListView to avoid layout assertions
                  if (replies.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('No replies yet.', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ListView.separated(
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
                              child: Text(
                                user.isNotEmpty ? user[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
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