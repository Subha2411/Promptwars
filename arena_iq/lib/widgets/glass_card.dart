import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurAmount;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.blurAmount = 15.0,
    this.padding = const EdgeInsets.all(16.0),
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppTheme.glassWhite.withOpacity(0.1),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppTheme.glassBorder, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: -2,
              )
            ]
          ),
          child: child,
        ),
      ),
    );
  }
}
