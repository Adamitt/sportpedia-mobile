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
      // chevinka: Responsive height untuk Android - diperkecil
      height: MediaQuery.of(context).size.width > 1024 ? 400 : (MediaQuery.of(context).size.width > 600 ? 280 : 240),
      // chevinka: Responsive untuk Android - diperkecil margin
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 1024 ? 48 : 16,
        vertical: MediaQuery.of(context).size.width > 1024 ? 32 : (MediaQuery.of(context).size.width > 600 ? 20 : 16),
      ),
      decoration: BoxDecoration(
        // chevinka: Responsive border radius untuk Android
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width > 1024 ? 68 : (MediaQuery.of(context).size.width > 600 ? 40 : 24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(-6, 7),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        // chevinka: Responsive border radius untuk Android
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width > 1024 ? 68 : (MediaQuery.of(context).size.width > 600 ? 40 : 24),
        ),
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
                      style: GoogleFonts.poppins( // chevinka: Gunakan Poppins - diperkecil
                        fontSize: MediaQuery.of(context).size.width > 1024 ? 42 : (MediaQuery.of(context).size.width > 600 ? 28 : 22),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.33,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width > 1024 ? 20 : 16),
                    ElevatedButton(
                      onPressed: onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlueDark.withValues(alpha: 0.9),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width > 1024 ? 28 : 24,
                          vertical: MediaQuery.of(context).size.width > 1024 ? 12 : 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'GET STARTED',
                        style: GoogleFonts.poppins( // chevinka: Gunakan Poppins - diperkecil
                          fontSize: MediaQuery.of(context).size.width > 1024 ? 14 : 12,
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

