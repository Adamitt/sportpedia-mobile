import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/sportforum/models/forum_entry.dart';

class ForumEntryCard extends StatelessWidget {
  final ForumEntry forum;
  final VoidCallback onTap;
  final String? currentUsername;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Future<void> Function()? onLike;
  final bool userHasLiked;

  const ForumEntryCard({
    super.key,
    required this.forum,
    required this.onTap,
    this.currentUsername,
    this.onEdit,
    this.onDelete,
    this.onLike,
    this.userHasLiked = false,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          elevation: 0,
          color: Colors.white,
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
                            forum.title,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Color(0xFF111827), // Gray 900
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                ownerLabel,
                                style: const TextStyle(
                                  color: Color(0xFF4B5563), // Gray 600
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "·",
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF), // Gray 400
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280), // Gray 500
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isOwner)
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_horiz, color: Color(0xFF9CA3AF)),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                if (onEdit != null) onEdit!();
                                break;
                              case 'delete':
                                if (onDelete != null) onDelete!();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.green, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit', style: TextStyle(color: Colors.green)),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // CONTENT
                Text(
                  forum.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF374151), // Gray 700
                    fontSize: 14.0,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 16),

                // TAGS & METRICS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags Row
                    Builder(
                      builder: (context) {
                        final bool hasHighlight = forum.repliesCount > 20;
                        final List<String> tags = forum.tags;

                        final List<Widget> chipRow = [];
                        if (hasHighlight) {
                          chipRow.add(const _ChipPill(
                            label: 'Highlight',
                            bg: Color(0xFFFEF3C7), // Amber 100
                            fg: Color(0xFF92400E), // Amber 800
                            bold: true,
                          ));
                        }
                        // Sport Category
                        chipRow.add(_ChipPill(
                          label: forum.sport,
                          bg: const Color(0xFFDBEAFE), // Blue 100
                          fg: const Color(0xFF1E40AF), // Blue 800
                          bold: true,
                        ));

                        // Tags
                        int visCount = 0;
                        if (tags.isNotEmpty) {
                          chipRow.add(_ChipPill(
                            label: '#${tags[0]}',
                            bg: const Color(0xFFF3F4F6), // Gray 100
                            fg: const Color(0xFF4B5563), // Gray 600
                          ));
                          visCount = 1;
                        }
                        final int remaining = tags.length - visCount;
                        if (remaining > 0) {
                          chipRow.add(_ChipPill(
                            label: '+$remaining',
                            bg: const Color(0xFFF3F4F6),
                            fg: const Color(0xFF4B5563),
                          ));
                        }

                        final List<Widget> children = <Widget>[];
                        for (int i = 0; i < chipRow.length; i++) {
                          if (i != 0) children.add(const SizedBox(width: 8));
                          children.add(chipRow[i]);
                        }
                        return Row(children: children);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Metrics Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _InteractiveMetric(
                          icon: userHasLiked ? Icons.favorite : Icons.favorite_border,
                          iconColor: userHasLiked ? Colors.red : const Color(0xFF6B7280),
                          value: forum.likes,
                          onTap: () async {
                            if (onLike != null) {
                              await onLike!();
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        _Metric(icon: Icons.remove_red_eye_outlined, value: forum.views),
                        const SizedBox(width: 20),
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
        Icon(icon, size: 18, color: const Color(0xFF9CA3AF)), // Gray 400
        const SizedBox(width: 6),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Color(0xFF6B7280), // Gray 500
            fontSize: 13,
            fontWeight: FontWeight.w500,
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
  final Color? iconColor;

  const _InteractiveMetric({
    required this.icon,
    required this.value,
    this.onTap,
    this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const Color defaultColor = Color(0xFF9CA3AF); // Gray 400
    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: iconColor ?? defaultColor),
              const SizedBox(width: 6),
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Color(0xFF6B7280), // Gray 500
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}