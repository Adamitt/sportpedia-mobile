import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuickNavigationSection extends StatelessWidget {
  const QuickNavigationSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi ukuran layar
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
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
                  // [FIX] Garis dekorasi mengecil/hilang di layar sangat kecil
                  if (screenWidth > 350)
                    Container(
                      width: isMobile ? 24 : 48,
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

                  SizedBox(width: isMobile ? 8 : 12),

                  // [FIX] Gunakan Flexible agar teks bisa menyesuaikan lebar
                  Flexible(
                    child: Text(
                      'Explore Features',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            isMobile ? 24 : 32, // Font lebih kecil di mobile
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
                  ),

                  SizedBox(width: isMobile ? 8 : 12),

                  if (screenWidth > 350)
                    Container(
                      width: isMobile ? 24 : 48,
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
                textAlign: TextAlign.center,
                style: TextStyle(
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
                crossAxisCount: screenWidth > 600 ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // [FIX] Aspect Ratio disesuaikan
                childAspectRatio: 0.85,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildQuickNavCard(context, index);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Fun Facts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.5,
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
        'description': 'History, rules, and guides.',
        'image': 'assets/images/sportlibrary.png',
        'color': Colors.blue,
        'badge': '50+',
        'route': '/library',
      },
      {
        'title': 'Community',
        'description': 'Share tips with lovers.',
        'image': 'assets/images/community.png',
        'color': Colors.purple,
        'badge': 'Active',
        'route': '/community',
      },
      {
        'title': 'Gear Guide',
        'description': 'Find the right equipment.',
        'image': 'assets/images/gearguide.png',
        'color': Colors.orange,
        'badge': 'Guide',
        'route': '/gearguide',
      },
      {
        'title': 'Video Gallery',
        'description': 'Visual tutorials for all.',
        'image': 'assets/images/video.png',
        'color': Colors.red,
        'badge': 'Videos',
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
            final title = item['title'] as String;
            if (title == 'Sports Library') {
              Navigator.pushNamed(context, '/sportlibrary');
            } else if (title == 'Gear Guide') {
              Navigator.pushNamed(context, '/gearguide');
            } else if (title == 'Video Gallery') {
              Navigator.pushNamed(context, '/videos');
            } else if (title == 'Community') {
              Navigator.pushNamed(context, '/community');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Coming soon'),
                    duration: Duration(seconds: 1)),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                const SizedBox(height: 4),

                // Image
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    item['image'] as String,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.category,
                          size: 24, color: item['color'] as Color);
                    },
                  ),
                ),
                const SizedBox(height: 6),

                // Title
                Text(
                  item['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Description
                Flexible(
                  child: Text(
                    item['description'] as String,
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
      {'value': '50+', 'label': 'Sports', 'color': Colors.blue},
      {'value': '200+', 'label': 'Members', 'color': Colors.purple},
      {'value': '300+', 'label': 'Gears', 'color': Colors.orange},
      {'value': '100+', 'label': 'Videos', 'color': Colors.red},
    ];

    final fact = facts[index];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (fact['color'] as Color).withValues(alpha: 0.1),
            (fact['color'] as Color).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: fact['color'] as Color,
            ),
          ),
          Text(
            fact['label'] as String,
            style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
