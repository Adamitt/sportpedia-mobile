import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // chevinka: Google Fonts untuk konsistensi dengan angie
import '../theme/app_colors.dart';

class QuickNavigationSection extends StatelessWidget {
  const QuickNavigationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // chevinka: Responsive untuk Android
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.width > 1024 ? 48 : 32,
        horizontal: MediaQuery.of(context).size.width > 1024 ? 48 : 16,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          // Section Header
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 2,
                    decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primaryBlue,
                        Colors.transparent,
                      ],
                    ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Explore Features',
                    style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                      fontSize: MediaQuery.of(context).size.width > 1024 ? 32 : 24, // Responsive font size
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          AppColors.primaryBlueDark,
                          AppColors.primaryBlue,
                        ],
                      ).createShader(
                          const Rect.fromLTWH(0, 0, 200, 70),
                        ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 2,
                    decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primaryBlue,
                        Colors.transparent,
                      ],
                    ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your path to sports excellence',
                style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Quick Nav Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildQuickNavCard(context, index);
              },
            ),
          ),

          const SizedBox(height: 32),

          // Fun Facts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildFunFactCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavCard(BuildContext context, int index) {
    final items = [
      {
        'title': 'Sports Library',
        'description': 'Explore sports fundamentals — history, rules, and beginner guides.',
        'image': 'assets/images/sportlibrary.png',
        'color': Colors.blue,
        'badge': '50+ Sports',
        'route': '/library',
      },
      {
        'title': 'Community',
        'description': 'A space to share tips, and motivation with sports lovers.',
        'image': 'assets/images/community.png',
        'color': Colors.purple,
        'badge': 'Active',
        'route': '/forum',
      },
      {
        'title': 'Gear Guide',
        'description': 'Find the right equipment for your game, choose, and play smarter.',
        'image': 'assets/images/gearguide.png',
        'color': Colors.orange,
        'badge': '⭐ Guide',
        'route': '/gearguide',
      },
      {
        'title': 'Video Gallery',
        'description': 'Learn visually with step-by-step sports tutorials for every level.',
        'image': 'assets/images/video.png',
        'color': Colors.red,
        'badge': '📹 40+ Videos',
        'route': '/videos',
      },
    ];

    final item = items[index];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
        child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            final route = item['route'] as String;
            if (route == '/gearguide') {
              Navigator.pushNamed(context, '/gearguide');
            } else {
              // Untuk route lain, show coming soon
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item['title']} page coming soon'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item['badge'] as String,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: item['color'] as Color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Image dari asset
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    item['image'] as String,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback ke icon jika gambar tidak ada
                      return Icon(
                        Icons.category,
                        size: 28,
                        color: item['color'] as Color,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),

                // Title
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Description
                Expanded(
                  child: Text(
                    item['description'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),

                // Button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: (item['color'] as Color).withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: item['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: item['color'] as Color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFunFactCard(int index) {
    final facts = [
      {'value': '50+', 'label': 'Sports Covered', 'color': Colors.blue},
      {'value': '200+', 'label': 'Active Members', 'color': Colors.purple},
      {'value': '300+', 'label': 'Gear Reviews', 'color': Colors.orange},
      {'value': '100+', 'label': 'Video Tutorials', 'color': Colors.red},
    ];

    final fact = facts[index];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (fact['color'] as Color).withValues(alpha: 0.1),
            (fact['color'] as Color).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (fact['color'] as Color).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            fact['value'] as String,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: fact['color'] as Color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fact['label'] as String,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

