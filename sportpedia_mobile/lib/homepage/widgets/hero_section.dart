import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // chevinka: Google Fonts untuk konsistensi dengan angie
import '../theme/app_colors.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback? onGetStarted;

  const HeroSection({super.key, this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // chevinka: Responsive height untuk Android
      height: MediaQuery.of(context).size.width > 1024 ? 500 : 350,
      // chevinka: Responsive untuk Android
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 1024 ? 48 : 16,
        vertical: MediaQuery.of(context).size.width > 1024 ? 40 : 24,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(68),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(-6, 7),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(68),
        child: Stack(
          children: [
            // Background image (kamu bisa ganti dengan NetworkImage jika punya URL)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlueDark,
                    AppColors.primaryBlue.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Image.asset(
                'assets/images/heroSection.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback gradient jika gambar tidak ada
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryBlueDark,
                          AppColors.primaryBlue,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Overlay sesuai Django
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    AppColors.primaryBlueDark.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
            // Content
            Center(
              child: Padding(
                // chevinka: Responsive padding untuk Android
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 1024 ? 48 : 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Satu Langkah ke Arena,\nSeribu Peluang Beraksi',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                        fontSize: MediaQuery.of(context).size.width > 1024 ? 56 : 32, // Responsive font size
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.33,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(0, 4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlueDark.withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        'GET STARTED',
                        style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

