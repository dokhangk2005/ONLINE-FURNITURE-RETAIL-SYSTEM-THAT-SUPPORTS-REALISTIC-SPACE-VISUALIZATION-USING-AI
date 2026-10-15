import 'package:flutter/material.dart';

// ─── Responsive Breakpoints ───────────────────────────────────────────────────
enum ScreenSize { mobile, tablet, desktop }

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  ScreenSize get screenSize {
    final w = screenWidth;
    if (w < 600) return ScreenSize.mobile;
    if (w < 1024) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;
}
