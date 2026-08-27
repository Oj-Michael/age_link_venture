import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static const double designWidth = 1440.0;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isMobile(BuildContext context) => screenWidth(context) < 768;

  static bool isCompact(BuildContext context) => screenWidth(context) < 1024;

  static bool isNarrow(BuildContext context) => screenWidth(context) < 1200;

  static double scale(BuildContext context) {
    final width = screenWidth(context);
    const densityFactor = 0.875;

    if (width >= designWidth) return densityFactor;
    return densityFactor * (width / designWidth).clamp(0.8, 1.0);
  }

  static double sz(BuildContext context, double value) =>
      value * scale(context);

  static EdgeInsets pagePadding(BuildContext context) {
    final base = isMobile(context) ? 12.0 : 16.0;
    return EdgeInsets.all(sz(context, base));
  }

  static double sidebarWidth(BuildContext context) => sz(context, 250);
}
