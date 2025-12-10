import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // chevinka: Google Fonts untuk konsistensi dengan angie
import '../theme/app_colors.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // chevinka: Responsive untuk Android
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 1024 ? 48 : 16,
        vertical: MediaQuery.of(context).size.width > 1024 ? 40 : 24,
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) {
            // Gradient dengan animasi shimmer effect
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentRedDark,
                AppColors.accentRed,
                AppColors.accentRedDark,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 3),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.linear,
            builder: (context, value, child) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment(-1.0 + value * 2, 0),
                    end: Alignment(1.0 + value * 2, 0),
                    colors: [
                      AppColors.accentRedDark,
                      AppColors.accentRed,
                      AppColors.accentRedDark,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Text(
                  'Hello, Are you new here?',
                  style: GoogleFonts.poppins( // chevinka: Gunakan Poppins
                    fontSize: MediaQuery.of(context).size.width > 1024 ? 30 : 24, // Responsive font size
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

