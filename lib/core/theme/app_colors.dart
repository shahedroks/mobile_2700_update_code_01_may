import 'package:flutter/material.dart';

/// TruckFix prototype palette (dark UI).
abstract final class AppColors {
  static const Color bg = Color(0xFF080808);
  static const Color bgElevated = Color(0xFF0A0A0A);
  static const Color card = Color(0xFF0F0F0F);
  static const Color card2 = Color(0xFF111111);
  static const Color border = Color(0xFF1A1A1A);
  static const Color border2 = Color(0xFF2A2A2A);
  static const Color primary = Color(0xFFFBBF24);
  static const Color primaryAlt = Color(0xFFFFD700);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF); // readable gray
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF4B5563);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color orange = Color(0xFFFB923C);

  // Aliases used across auth / onboarding screens
  static const Color textGray = textSecondary;
  static const Color textWhite = textPrimary;
  static const Color borderLight = border2;
  static const Color success = green;
  static const Color successBg = Color(0x3316A34A);
  static const Color error = red;
}
