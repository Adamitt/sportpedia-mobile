import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/sportforum/models/forum_entry.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart' as pbp;
import 'package:sportpedia_mobile/sportforum/screens/forum_edit_form.dart';
import 'package:sportpedia_mobile/sportforum/services/forum_service.dart';

class ForumDetailPage extends StatefulWidget {
  final ForumEntry forum;
  final pbp.CookieRequest request;

  const ForumDetailPage({super.key, required this.forum, required this.request});

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final TextEditingController _replyController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

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
    return ForumService.fetchDetail(request, widget.forum.id);
  }

  Future<void> _toggleLike(pbp.CookieRequest request) async {
    try {
      await ForumService.toggleLike(request, widget.forum.id);
    } finally {
      setState(() {});
    }
  }

  Future<void> _postReply(pbp.CookieRequest request) async {
    final String comment = _replyController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a reply first.')),
      );
      return;
    }
    setState(() {
      _isPosting = true;
    });
    try {
      // Expected Django endpoint to create a reply for a forum post
      await ForumService.postReply(request, widget.forum.id, comment);
      _replyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply posted.')),
      );
      // Refresh detail to include the new reply
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post reply: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
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
                      await ForumService.deletePost(widget.request, widget.forum.id);
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
                  // HEADER: Avatar + Title + Meta
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFEFF6FF), // Blue 50
                        child: Text(
                          avatarInitial,
                          style: const TextStyle(
                            color: Color(0xFF1D4ED8), // Blue 700
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.forum.title,
                              style: const TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFF111827), // Gray 900
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  displayAuthor,
                                  style: const TextStyle(
                                    color: Color(0xFF4B5563), // Gray 600
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "·",
                                  style: TextStyle(
                                    color: Color(0xFF9CA3AF), // Gray 400
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(widget.forum.datePosted),
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280), // Gray 500
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // CONTENT
                  Text(
                    widget.forum.content,
                    style: const TextStyle(
                      color: Color(0xFF374151), // Gray 700
                      fontSize: 16.0,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 20),

                  // TAGS
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Highlight if many replies
                      if ((detail['replies'] as List?)?.length != null && ((detail['replies'] as List?)?.length ?? 0) > 20)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7), // Amber 100
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Highlight',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF92400E), // Amber 800
                            ),
                          ),
                        ),
                      // Sport chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE), // Blue 100
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          widget.forum.sport,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E40AF), // Blue 800
                          ),
                        ),
                      ),
                      // Tags
                      ...((widget.forum.tags ?? const <String>[]) as List<String>).map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6), // Gray 100
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '#$t',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4B5563), // Gray 600
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 12),

                  // METRICS
                  Row(
                    children: [
                      // Like Button
                      Material(
                        color: Colors.transparent,
                        shape: const StadiumBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _toggleLike(request),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  userHasLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 20,
                                  color: userHasLiked ? Colors.red : const Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$likes',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Views
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, size: 20, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.forum.views}',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Replies Count
                      Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 20, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 6),
                          Text(
                            '${replies.length}',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                              
                  // Replies section
                  const Text(
                    'Replies',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Reply input box
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB), // Gray 50
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)), // Gray 200
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add a reply',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _replyController,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Write your thoughts...',
                            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            height: 36,
                            child: ElevatedButton.icon(
                              onPressed: _isPosting ? null : () => _postReply(request),
                              icon: _isPosting
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.send, size: 16),
                              label: Text(
                                _isPosting ? 'Posting...' : 'Post Reply',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Replies list
                  if (replies.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'No replies yet. Be the first to share your thoughts!',
                          style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: replies.length,
                      separatorBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                      ),
                      itemBuilder: (context, index) {
                        final r = replies[index] as Map<String, dynamic>;
                        final user = (r['user'] ?? 'Unknown').toString();
                        final comment = (r['comment'] ?? '').toString();
                        final date = _formatDateIso(r['date']?.toString());
                        final userInitial = user.isNotEmpty ? user[0].toUpperCase() : '?';
                        
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFFF3F4F6),
                              child: Text(
                                userInitial,
                                style: const TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        user,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        date,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF374151),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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