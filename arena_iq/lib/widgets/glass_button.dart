import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_theme.dart';

class GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color baseColor;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.baseColor = AppTheme.accentCyan,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: baseColor.withOpacity(0.5), width: 1),
              boxShadow: [
                 BoxShadow(
                   color: baseColor.withOpacity(0.3),
                   blurRadius: 20,
                   spreadRadius: -5,
                 )
              ]
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
