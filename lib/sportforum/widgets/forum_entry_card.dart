import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/sportforum/models/forum_entry.dart';

class ForumEntryCard extends StatelessWidget {
  final ForumEntry forum;
  final VoidCallback onTap;
  final String? currentUsername;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Future<void> Function()? onLike;

  const ForumEntryCard({
    super.key,
    required this.forum,
    required this.onTap,
    this.currentUsername,
    this.onEdit,
    this.onDelete,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOwner = currentUsername != null &&
    forum.author == currentUsername;
    final String displayAuthor =
      forum.author.isNotEmpty ? forum.author : 'Unknown';
    final String ownerLabel = displayAuthor;
    final String avatarInitial =
      displayAuthor.isNotEmpty ? displayAuthor[0].toUpperCase() : '?';
    final String formattedDate = _formatDate(forum.datePosted);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          elevation: 1.5,
          shadowColor: Colors.black.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // BAGIAN PERTAMA
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
                                    forum.title,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Color.fromRGBO(17, 24, 39, 1),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      Text(
                                      ownerLabel,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 2),

                                      Text(
                                        " · ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 2),

                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 2),


                                    ]
                                  )
                                  
                                  
                                ],
                                
                              ),
                            ],
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


                const SizedBox(height: 4),
                const Divider(height: 2, thickness: 1, color: Color(0xFFE5E7EB)),
                const SizedBox(height: 12),


                // BAGIAN KEDUA
                // Content preview
                Padding(
                  padding: EdgeInsetsGeometry.only(left: 8.0),
                  child: Text(
                    forum.content.length > 100
                        ? '${forum.content.substring(0, 100)}...'
                        : forum.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 16, 16, 16),
                      fontSize: 14.0,
                      ),
                  ),
                ),
                const SizedBox(height: 16),                


                // BAGIAN KETIGA
                // row, di dalemnya ada kolom buat owner sama tanggal, love, views, replies count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Flexible(
                      child: Wrap(
                        spacing: 2,
                        runSpacing: 6,
                        children: [
                          if (forum.repliesCount > 20)
                            const _ChipPill(
                              label: 'Highlight',
                              bg: Color(0xFFFFE69A),
                              fg: Color(0xFF1F2937),
                              bold: true,
                            ),
                          _ChipPill(
                            label: forum.sport,
                            bg: const Color(0xFF1E3A8A),
                            fg: Colors.white,
                            bold: true,
                          ),
                          ...forum.tags.map(
                            (t) => const SizedBox(),
                          ).toList(),
                          ...forum.tags.map(
                            (t) => _ChipPill(
                              label: '#$t',
                              bg: const Color(0xFFF3F4F6),
                              fg: const Color(0xFF4B5563),
                              border: const Color(0xFFE5E7EB),
                            ),
                          ),
                        ],
                      ),
                    ),

                    
                    
                    // ================================
                    // RIGHT SIDE — likes, views, replies
                    // ================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _InteractiveMetric(
                          icon: Icons.favorite_border,
                          value: forum.likes,
                          onTap: () async {
                            if (onLike != null) {
                              await onLike!();
                            }
                          },
                        ),
                        const SizedBox(width: 14),
                        _Metric(icon: Icons.remove_red_eye_outlined, value: forum.views),
                        const SizedBox(width: 14),
                        _Metric(icon: Icons.chat_bubble_outline, value: forum.repliesCount),
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
    final DateTime now = DateTime.now().toLocal();
    final DateTime localDate = date.toLocal();
    final Duration diff = now.difference(localDate);

    if (diff.inHours < 24) {
      final int hours = diff.inHours <= 0 ? 1 : diff.inHours; // minimum 1h
      return '${hours}h ago';
    } else {
      final int days = diff.inDays <= 0 ? 1 : diff.inDays; // minimum 1d
      return '${days}d ago';
    }
  }
}

class _ChipPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final Color? border;
  final bool bold;
  const _ChipPill({
    required this.label,
    required this.bg,
    required this.fg,
    this.border,
    this.bold = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w300,
          height: 1.2,
          letterSpacing: 0.80,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final int value;
  const _Metric({required this.icon, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 2),
        Icon(icon, size: 15, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _InteractiveMetric extends StatelessWidget {
  final IconData icon;
  final int value;
  final Future<void> Function()? onTap;

  const _InteractiveMetric({
    required this.icon,
    required this.value,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const Color fg = Color(0xFF6B7280);
    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        hoverColor: Colors.black12,
        splashColor: Colors.black12,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 4),
              Text(
                value.toString(),
                style: const TextStyle(
                  color: fg,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}