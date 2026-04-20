import 'package:flutter/material.dart';
import '../models/venue_zone.dart';

extension DensityColorExtension on VenueZone {
  /// Returns the color representing the current density level.
  Color get densityColor {
    if (density < 0.35) return const Color(0xFF69F0AE); // accentGreen
    if (density < 0.65) return const Color(0xFFFFD740); // accentYellow
    return const Color(0xFFFF5252); // accentRed
  }
  
  /// Formats density as a percentage string (e.g. "45%").
  String get densityPercentage => '${(density * 100).round()}%';
}

extension ContextExtensions on BuildContext {
  /// Helper to get the top padding (safe area).
  double get topPadding => MediaQuery.of(this).padding.top;
  
  /// Helper to get bottom padding (safe area).
  double get bottomPadding => MediaQuery.of(this).padding.bottom;
}
