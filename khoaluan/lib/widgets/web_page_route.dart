import 'package:flutter/material.dart';

class WebPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool animated;

  WebPageRoute({required this.page, this.animated = false, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: animated
            ? const Duration(milliseconds: 300)
            : Duration.zero,
        reverseTransitionDuration: animated
            ? const Duration(milliseconds: 250)
            : Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (!animated) return child;

          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
            reverseCurve: Curves.easeInOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0.0), // Subtle slide from right
              end: Offset.zero,
            ).animate(curve),
            child: FadeTransition(opacity: curve, child: child),
          );
        },
      );
}
