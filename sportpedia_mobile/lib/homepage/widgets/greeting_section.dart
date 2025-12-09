import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
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
                child: const Text(
                  'Hello, Are you new here?',
                  style: TextStyle(
                    fontSize: 30,
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

