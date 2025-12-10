import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportpedia_mobile/models/gear_list.dart';
import 'package:url_launcher/url_launcher.dart';

class GearDetailPage extends StatelessWidget {
  final Datum datum;

  const GearDetailPage({super.key, required this.datum});

  static const Color primaryDark = Color(0xFF1C3264);
  static const Color primaryMid = Color(0xFF2A4B97);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);

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

  Widget _buildTagChip(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue.withOpacity(0.1), accentPurple.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: primaryBlue),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryDark,
            ),
          ),
        ],
      ),
    );
  }

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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryBlue, accentPurple],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: primaryDark,
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

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(0.1),
            accentPurple.withOpacity(0.1),
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = (datum.image ?? '').isNotEmpty ? datum.image : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar dengan Gradient
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: primaryDark,
            elevation: 0,
            centerTitle: true,
            
            title: Text(
              'Gear Details',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryDark, primaryMid, primaryBlue],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                    child: Hero(
                      tag: 'gear-${datum.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (imageUrl != null)
                                Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _placeholderImage(),
                                )
                              else
                                _placeholderImage(),
                              
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.15),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title Section dengan Gradient
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryBlue, accentPurple],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title dengan flexible width
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              datum.name ?? '-',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.3,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Badges dalam Row dengan proper spacing
                          Row(
                            children: [
                              // Sport Badge
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.sports_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          datum.sportName ?? '-',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Level Badge
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
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
                                      Flexible(
                                        child: Text(
                                          _getLevelConfig()['text'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _getLevelConfig()['color'],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Price Range Card
                    if ((datum.priceRange ?? '').isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryBlue.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [primaryBlue, accentPurple],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryBlue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.attach_money_rounded,
                                color: Colors.white,
                                size: 24,
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
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    datum.priceRange ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: primaryDark,
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

                    // Detail Sections
                    if ((datum.function ?? '').isNotEmpty)
                      _buildSectionCard(
                        title: 'Function',
                        icon: Icons.stars_rounded,
                        content: Text(
                          datum.function ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.6,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),

                    if ((datum.description ?? '').isNotEmpty)
                      _buildSectionCard(
                        title: 'Description',
                        icon: Icons.description_outlined,
                        content: Text(
                          datum.description ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.6,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),

                    if (datum.recommendedBrands != null &&
                        datum.recommendedBrands!.isNotEmpty)
                      _buildSectionCard(
                        title: 'Recommended Brands',
                        icon: Icons.verified_outlined,
                        content: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: datum.recommendedBrands!
                              .map((brand) => _buildTagChip(
                                    brand,
                                    icon: Icons.check_circle_outline_rounded,
                                  ))
                              .toList(),
                        ),
                      ),

                    if (datum.materials != null && datum.materials!.isNotEmpty)
                      _buildSectionCard(
                        title: 'Materials',
                        icon: Icons.layers_outlined,
                        content: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: datum.materials!
                              .map((material) => _buildTagChip(
                                    material,
                                    icon: Icons.label_outline_rounded,
                                  ))
                              .toList(),
                        ),
                      ),

                    if ((datum.careTips ?? '').isNotEmpty)
                      _buildSectionCard(
                        title: 'Care Tips',
                        icon: Icons.health_and_safety_outlined,
                        content: Text(
                          datum.careTips ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.6,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),

                    if (datum.tags != null && datum.tags!.isNotEmpty)
                      _buildSectionCard(
                        title: 'Tags',
                        icon: Icons.local_offer_outlined,
                        content: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: datum.tags!
                              .map((tag) => _buildTagChip(
                                    tag,
                                    icon: Icons.tag_rounded,
                                  ))
                              .toList(),
                        ),
                      ),

                    // Buy Button dengan Gradient
                    if ((datum.ecommerceLink ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primaryBlue, accentPurple],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _launchUrl(datum.ecommerceLink!),
                            borderRadius: BorderRadius.circular(20),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Buy Now',
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}