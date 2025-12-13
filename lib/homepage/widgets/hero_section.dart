import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback? onGetStarted;

  const HeroSection({super.key, this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    // Deteksi ukuran layar
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      // Margin lebih kecil di mobile agar kartu lebih lebar
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 12,
      ),
      // [FIX] AspectRatio Responsif:
      // Mobile = 1.2 (Lebih tinggi/kotak) supaya muat teks & tombol
      // Desktop = 2.4 (Lebar/Panjang)
      child: AspectRatio(
        aspectRatio: isMobile ? 1.2 : 2.4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(-4, 6),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // 1. Background Image
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryBlueDark,
                        AppColors.primaryBlue.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/heroSection.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
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

                // 2. Overlay Gelap
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),

                // 3. Content
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // [FIX] Flexible agar teks bisa turun baris jika sempit
                        Flexible(
                          child: Text(
                            'Satu Langkah ke Arena,\nSeribu Peluang Beraksi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // [FIX] Font lebih kecil di mobile (22) agar aman
                              fontSize: isMobile ? 22 : 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.6),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 24),

                        ElevatedButton(
                          onPressed: onGetStarted,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlueDark,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 24 : 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            'GET STARTED',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
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
        ),
      ),
    );
  }
}