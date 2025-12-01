import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/sportforum/models/forum_entry.dart';

class ForumEntryCard extends StatelessWidget {
  final ForumEntry forum;
  final VoidCallback onTap;
  final String? currentUsername;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ForumEntryCard({
    super.key,
    required this.forum,
    required this.onTap,
    this.currentUsername,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOwner = currentUsername != null &&
    forum.author == currentUsername;
    final String displayAuthor =
      forum.author.isNotEmpty ? forum.author : 'Unknown';
    final String ownerLabel = 'Owner: $displayAuthor';
    final String avatarInitial =
      displayAuthor.isNotEmpty ? displayAuthor[0].toUpperCase() : '?';
    final String formattedDate = _formatDate(forum.datePosted);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // highlight, Sport, tags, and overflow actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (forum.repliesCount > 20)
                            const Text(
                              'highlight',
                              style: TextStyle(
                                backgroundColor: Color(0xFFFFDD78),
                                color: Colors.black,
                              ),
                            ),
                          Text(
                            forum.sport,
                            style: const TextStyle(
                              backgroundColor: Colors.blue,
                              color: Colors.white,
                            ),
                          ),
                          ...forum.tags.map(
                            (t) => Text(
                              t,
                              style: const TextStyle(
                                backgroundColor: Color.fromRGBO(243, 244, 246, 1),
                                color: Color.fromRGBO(75, 85, 99, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isOwner)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              if (onEdit != null) {
                                onEdit!();
                              }
                              break;
                            case 'delete':
                              if (onDelete != null) {
                                onDelete!();
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: const [
                                Icon(Icons.edit, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: const [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Forum Title
                Text(
                  forum.title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Color.fromRGBO(17, 24, 39, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Content preview
                Text(
                  forum.content.length > 100
                      ? '${forum.content.substring(0, 100)}...'
                      : forum.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 6),                

                // row, di dalemnya ada kolom buat owner sama tanggal, love, views, replies count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // ================================
                    // LEFT SIDE — avatar + owner + date
                    // ================================
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blue,
                          child: Text(
                            avatarInitial,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ownerLabel,
                              style: TextStyle(
                                color: Color.fromRGBO(17, 24, 39, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // ================================
                    // RIGHT SIDE — likes, views, replies
                    // ================================
                    Row(
                      children: [
                        // ❤️ LIKE BUTTON
                        InkWell(
                          onTap: () {
                            // TODO: Tambahkan fungsi like
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                forum.likes.toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 👁️ VIEWS
                        Row(
                          children: [
                            const Icon(
                              Icons.remove_red_eye_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              forum.views.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // 💬 REPLIES
                        Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              forum.repliesCount.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  ],
                ),   
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateTime localDate = date.toLocal();
    final String day = localDate.day.toString().padLeft(2, '0');
    final String month = localDate.month.toString().padLeft(2, '0');
    final String year = localDate.year.toString();
    final String hour = localDate.hour.toString().padLeft(2, '0');
    final String minute = localDate.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}