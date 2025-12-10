import 'package:flutter/material.dart';

// chevinka: Updated color palette to match angie's design system (login, register, gearguide)
class AppColors {
  // Primary Colors (Blue) - Sesuai Design System Angie
  static const Color primaryBlue = Color(0xFF17356B);
  static const Color primaryBlueDark = Color(0xFF1C3264); // primaryDark
  static const Color primaryMid = Color(0xFF2A4B97); // primaryMid (untuk gradient)

  // Accent Colors (Red/Coral) - Sesuai Design System Angie
  static const Color accentRed = Color(0xFFC94A4A);
  static const Color accentRedDark = Color(0xFF992626); // primaryRed

  // Text Colors - Sesuai Design System Angie
  static const Color textGrey = Color(0xFF6C7278); // textGrey dari login page
  static const Color textDark = Color(0xFF111827);
  static const Color textGray = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Background Colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F7FA); // Scaffold background dari angie
  static const Color backgroundPinkLight = Color(0xFFFFF8F8);
  static const Color backgroundPinkLighter = Color(0xFFFFF5F5);
  static const Color backgroundPinkLightest = Color(0xFFFEF0F0);

  // Card Colors
  static const Color cardBorder = Color(0xFFE6CACA);
  static const Color cardBackground = Color(0xFFFFF8F8);
  static const Color cardBackgroundWithOpacity = Color(0xC9FFF8F8);

  // Testimonial Colors
  static const Color testimonialCardBg = Color(0x80FFF3F3); // rgba(255,243,243,0.50)
  static const Color testimonialCardBorder = Color(0x8A9A6A6A); // rgba(154,106,106,0.54)

  // Gradient Colors - Sesuai Design System Angie
  static LinearGradient greetingGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentRedDark,
      accentRed,
      accentRedDark,
    ],
  );

  // chevinka: Gradient sesuai login page angie
  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment(-0.1, -0.3),
    end: Alignment(1.0, 0.5),
    colors: [
      primaryBlueDark, // _primaryDark
      primaryMid, // _primaryMid
      accentRedDark, // _primaryRed
    ],
  );

  static LinearGradient whatsHotBackgroundGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundWhite,
      backgroundPinkLighter,
      backgroundPinkLightest,
    ],
  );
}

