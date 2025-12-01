import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/sportforum/models/forum_entry.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ForumDetailPage extends StatelessWidget {
  final ForumEntry forum;

  const ForumDetailPage({super.key, required this.forum});

  String _formatDate(DateTime date) {
    // Simple date formatter without intl package
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }


  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    int? _extractUserId(Map<String, dynamic> jd) {
      final dynamic idCandidate = jd['id'] ?? jd['user_id'] ?? jd['userId'] ??
          (jd['user'] is Map ? jd['user']['id'] : null) ?? jd['pk'];
      if (idCandidate is int) return idCandidate;
      return idCandidate != null ? int.tryParse(idCandidate.toString()) : null;
    }

    final Map<String, dynamic> jd = Map<String, dynamic>.from(request.jsonData);
    final int? currentUserId = _extractUserId(jd);
    final String? currentUsername = jd['username']?.toString();
    final bool isMine = (forum.userUsername != null && currentUsername != null
      ? forum.userUsername!.toLowerCase() == currentUsername.toLowerCase()
      : (forum.userId != null && currentUserId != null && forum.userId == currentUserId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Highlight badge
                  if (forum.repliesCount > 20)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      margin: const EdgeInsets.only(bottom: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const Text(
                        'Highlight',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  // Title
                  Text(
                    forum.title,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category and Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade100,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          forum.sport.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(forum.datePosted),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ), const SizedBox(width: 12),
                      
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Owner info
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        forum.author != null
                            ? (isMine ? 'Owner: You' : 'Owner: ${forum.author}')
                            : (forum.userId != null
                                ? (isMine ? 'Owner: You' : 'Owner ID: ${forum.userId}')
                                : 'Owner: Unknown'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),

                  // Full content
                  Text(
                    forum.content,
                    style: const TextStyle(
                      fontSize: 16.0,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}