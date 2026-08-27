import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primary = Color(0xFFA32026);
  static const Color primaryDark = Color(0xFF6B0F14);
  static const Color gradientStart = Color(0xFF1A0A0C);
  static const Color gradientEnd = Color(0xFFC41E3A);
  static const Color background = Color(0xFF1A0A0C);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color pageBackground = Color(0xFFF4F6F9);
  static const Color border = Color(0xFFE2E5EB);
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF949DB1);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF7C3AED);
  static const Color badgePink = Color(0xFFFCE8E8);
}

abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract class AppLayout {
  static const double topBarHeight = 56;
  static const double kpiCardMinHeight = 108;
  static const double kpiCardPaddingH = 16;
  static const double kpiCardPaddingV = 18;
  static const double chartContentHeight = 292;
  static const double chartCardHeaderGap = 24;
  static const double chartYAxisReservedSize = 54;
  static const double chartDateRowHeight = 22;
  static const double heroStripHeight = 140;
}
