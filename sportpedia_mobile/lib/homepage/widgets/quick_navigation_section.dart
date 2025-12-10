import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // chevinka: Google Fonts untuk konsistensi dengan angie
import '../theme/app_colors.dart';

class QuickNavigationSection extends StatelessWidget {
  const QuickNavigationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // chevinka: Responsive untuk Android - diperkecil
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.width > 1024 ? 40 : (MediaQuery.of(context).size.width > 600 ? 28 : 24),
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
                    style: GoogleFonts.poppins( // chevinka: Gunakan Poppins - diperkecil
                      fontSize: MediaQuery.of(context).size.width > 1024 ? 28 : (MediaQuery.of(context).size.width > 600 ? 22 : 20),
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
                style: GoogleFonts.poppins( // chevinka: Gunakan Poppins, sesuaikan color palette
                  fontSize: MediaQuery.of(context).size.width > 1024 ? 12 : (MediaQuery.of(context).size.width > 600 ? 11 : 10), // chevinka: Responsive font size
                  color: AppColors.textGrey, // chevinka: Pakai textGrey dari color palette
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).size.width > 1024 ? 24 : 16),

          // Quick Nav Cards - chevinka: Perkecil grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width > 1024 ? 8 : 4),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: MediaQuery.of(context).size.width > 1024 ? 12 : 8,
                mainAxisSpacing: MediaQuery.of(context).size.width > 1024 ? 12 : 8,
                childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.1 : 1.0, // chevinka: Perkecil aspect ratio
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildQuickNavCard(context, index);
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.width > 1024 ? 24 : 16),

          // Fun Facts - chevinka: Perkecil grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width > 1024 ? 8 : 4),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2, // chevinka: 2 kolom di mobile
                crossAxisSpacing: MediaQuery.of(context).size.width > 1024 ? 8 : 6,
                mainAxisSpacing: MediaQuery.of(context).size.width > 1024 ? 8 : 6,
                childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.3 : 1.1, // chevinka: Perkecil aspect ratio
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildFunFactCard(context, index);
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
        'color': AppColors.primaryBlueDark, // chevinka: Sesuaikan dengan color palette
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
        'color': AppColors.accentRed, // chevinka: Sesuaikan dengan color palette
        'badge': '📹 40+ Videos',
        'route': '/videos',
      },
    ];

    final item = items[index];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textLight, width: 1), // chevinka: Sesuaikan dengan color palette
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
            } else if (route == '/videos') {
              // chevinka: Navigate ke Video Gallery
              Navigator.pushNamed(context, '/videos');
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
            padding: EdgeInsets.all(MediaQuery.of(context).size.width > 1024 ? 12 : 8), // chevinka: Perkecil padding
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
                      style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
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
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width > 1024 ? 8 : 6),
                  child: Image.asset(
                    item['image'] as String,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback ke icon jika gambar tidak ada
                      return Icon(
                        Icons.category,
                        size: MediaQuery.of(context).size.width > 1024 ? 28 : 22,
                        color: item['color'] as Color,
                      );
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width > 1024 ? 6 : 4),

                // Title - chevinka: Perkecil font
                Text(
                  item['title'] as String,
                  style: GoogleFonts.poppins( // chevinka: Gunakan Poppins - diperkecil
                    fontSize: MediaQuery.of(context).size.width > 1024 ? 13 : (MediaQuery.of(context).size.width > 600 ? 12 : 11),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: MediaQuery.of(context).size.width > 1024 ? 4 : 2),

                // Description - chevinka: Perkecil font
                Expanded(
                    child: Text(
                      item['description'] as String,
                      style: GoogleFonts.poppins( // chevinka: Gunakan Poppins - diperkecil
                        fontSize: MediaQuery.of(context).size.width > 1024 ? 9 : (MediaQuery.of(context).size.width > 600 ? 8 : 8),
                        color: AppColors.textGrey,
                      ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // chevinka: Kurangi maxLines
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width > 1024 ? 4 : 2),

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
                        style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
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

  Widget _buildFunFactCard(BuildContext context, int index) { // chevinka: Tambah BuildContext untuk responsive
    final facts = [
      {'value': '50+', 'label': 'Sports Covered', 'color': AppColors.primaryBlueDark}, // chevinka: Sesuaikan dengan color palette
      {'value': '200+', 'label': 'Active Members', 'color': Colors.purple},
      {'value': '300+', 'label': 'Gear Reviews', 'color': Colors.orange},
      {'value': '100+', 'label': 'Video Tutorials', 'color': AppColors.accentRed}, // chevinka: Sesuaikan dengan color palette
    ];

    final fact = facts[index];

    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width > 1024 ? 12 : 8), // chevinka: Perkecil padding
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
            style: GoogleFonts.poppins( // chevinka: Gunakan Poppins - diperkecil
              fontSize: MediaQuery.of(context).size.width > 1024 ? 18 : (MediaQuery.of(context).size.width > 600 ? 16 : 14),
              fontWeight: FontWeight.bold,
              color: fact['color'] as Color,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width > 1024 ? 4 : 2),
          Text(
            fact['label'] as String,
            style: GoogleFonts.poppins( // chevinka: Gunakan Poppins - diperkecil
              fontSize: MediaQuery.of(context).size.width > 1024 ? 9 : 8,
              color: AppColors.textGrey, // chevinka: Sesuaikan dengan color palette
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

