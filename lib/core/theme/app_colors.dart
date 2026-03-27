import 'package:flutter/material.dart';

/// App color palette with premium gradients and glassmorphism support
class AppColors {
  // Primary colors (Indigo)
  static const primary = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF3730A3);

  // Secondary colors (Violet/Purple)
  static const secondary = Color(0xFF8B5CF6);
  static const secondaryLight = Color(0xFFA78BFA);

  // Background colors
  static const backgroundStart = Color(0xFFEEF2FF); // Indigo 50
  static const backgroundEnd = Color(0xFFFFFFFF);

  // Neutral colors
  static const slate900 = Color(0xFF0F172A);
  static const slate800 = Color(0xFF1E293B);
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const slate400 = Color(0xFF94A3B8);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate50 = Color(0xFFF8FAFC);

  // Card backgrounds (for glassmorphism)
  static const glassBackground = Color(0xB3FFFFFF); // 70% white
  static const glassBorder = Color(0x4DFFFFFF); // 30% white

  // Status colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const bgGradient = LinearGradient(
    colors: [backgroundStart, backgroundEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF1F5F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
