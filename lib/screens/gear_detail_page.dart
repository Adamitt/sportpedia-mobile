import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportpedia_mobile/models/gear_list.dart';
import 'package:url_launcher/url_launcher.dart';

class GearDetailPage extends StatelessWidget {
  final Datum datum;

  const GearDetailPage({super.key, required this.datum});

  // ═══════════════════════════════════════════════════════════
  // LEVEL CONFIG
  // ═══════════════════════════════════════════════════════════
  Map<String, dynamic> _getLevelConfig() {
    switch (datum.level) {
      case Level.BEGINNER:
        return {
          'text': 'Beginner',
          'color': const Color(0xFF10B981),
          'bgColor': const Color(0xFFD1FAE5),
          'icon': Icons.emoji_events_outlined,
        };
      case Level.INTERMEDIATE:
        return {
          'text': 'Intermediate',
          'color': const Color(0xFFF59E0B),
          'bgColor': const Color(0xFFFEF3C7),
          'icon': Icons.trending_up,
        };
      case Level.ADVANCED:
        return {
          'text': 'Advanced',
          'color': const Color(0xFFEF4444),
          'bgColor': const Color(0xFFFEE2E2),
          'icon': Icons.workspace_premium,
        };
      default:
        return {
          'text': 'Unknown',
          'color': const Color(0xFF6B7280),
          'bgColor': const Color(0xFFF3F4F6),
          'icon': Icons.help_outline,
        };
    }
  }

  // ═══════════════════════════════════════════════════════════
  // LEVEL BADGE
  // ═══════════════════════════════════════════════════════════
  Widget _buildLevelBadge() {
    final config = _getLevelConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: config['bgColor'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config['color'].withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config['icon'], size: 16, color: config['color']),
          const SizedBox(width: 6),
          Text(
            config['text'],
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: config['color'],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAG CHIP
  // ═══════════════════════════════════════════════════════════
  Widget _buildTagChip(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: const Color(0xFF6366F1)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4338CA),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECTION CARD
  // ═══════════════════════════════════════════════════════════
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PLACEHOLDER IMAGE
  // ═══════════════════════════════════════════════════════════
  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 80,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LAUNCH URL
  // ═══════════════════════════════════════════════════════════
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = datum.image.isNotEmpty ? datum.image : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // ═══════════════════════════════════════════════════════════
          // APP BAR
          // ═══════════════════════════════════════════════════════════
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'gear-${datum.id}',
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF9FAFB), Colors.white],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 280,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholderImage(),
                            )
                          : _placeholderImage(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════
          // CONTENT
          // ═══════════════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─────────────────────────────────────────────────────
                  // HEADER SECTION
                  // ─────────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                datum.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.sports,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    datum.sportName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getLevelConfig()['icon'],
                                    size: 16,
                                    color: _getLevelConfig()['color'],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getLevelConfig()['text'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _getLevelConfig()['color'],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─────────────────────────────────────────────────────
                  // PRICE
                  // ─────────────────────────────────────────────────────
                  if (datum.priceRange.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.attach_money,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price Range',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  datum.priceRange,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF047857),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ─────────────────────────────────────────────────────
                  // FUNCTION
                  // ─────────────────────────────────────────────────────
                  if (datum.function.isNotEmpty)
                    _buildSectionCard(
                      title: 'Function',
                      icon: Icons.stars_rounded,
                      content: Text(
                        datum.function,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.6,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ),

                  // ─────────────────────────────────────────────────────
                  // DESCRIPTION
                  // ─────────────────────────────────────────────────────
                  if (datum.description.isNotEmpty)
                    _buildSectionCard(
                      title: 'Description',
                      icon: Icons.description_outlined,
                      content: Text(
                        datum.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.6,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ),

                  // ─────────────────────────────────────────────────────
                  // RECOMMENDED BRANDS
                  // ─────────────────────────────────────────────────────
                  if (datum.recommendedBrands.isNotEmpty)
                    _buildSectionCard(
                      title: 'Recommended Brands',
                      icon: Icons.verified_outlined,
                      content: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: datum.recommendedBrands
                            .map((brand) => _buildTagChip(
                                  brand,
                                  icon: Icons.check_circle_outline,
                                ))
                            .toList(),
                      ),
                    ),

                  // ─────────────────────────────────────────────────────
                  // MATERIALS
                  // ─────────────────────────────────────────────────────
                  if (datum.materials.isNotEmpty)
                    _buildSectionCard(
                      title: 'Materials',
                      icon: Icons.layers_outlined,
                      content: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: datum.materials
                            .map((material) => _buildTagChip(
                                  material,
                                  icon: Icons.label_outline,
                                ))
                            .toList(),
                      ),
                    ),

                  // ─────────────────────────────────────────────────────
                  // CARE TIPS
                  // ─────────────────────────────────────────────────────
                  if (datum.careTips.isNotEmpty)
                    _buildSectionCard(
                      title: 'Care Tips',
                      icon: Icons.health_and_safety_outlined,
                      content: Text(
                        datum.careTips,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.6,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ),

                  // ─────────────────────────────────────────────────────
                  // TAGS
                  // ─────────────────────────────────────────────────────
                  if (datum.tags.isNotEmpty)
                    _buildSectionCard(
                      title: 'Tags',
                      icon: Icons.local_offer_outlined,
                      content: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: datum.tags
                            .map((tag) => _buildTagChip(
                                  tag,
                                  icon: Icons.tag,
                                ))
                            .toList(),
                      ),
                    ),

                  // ─────────────────────────────────────────────────────
                  // BUY BUTTON
                  // ─────────────────────────────────────────────────────
                  if (datum.ecommerceLink.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _launchUrl(datum.ecommerceLink),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Buy Now',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}