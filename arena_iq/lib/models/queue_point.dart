import 'venue_zone.dart';

/// A queue point derived from a venue zone that has waiting capabilities.
class QueuePoint {
  final String zoneId;
  final String name;
  final ZoneType type;
  final double density;
  final int estimatedWaitMinutes;
  final WaitTrend trend;

  const QueuePoint({
    required this.zoneId,
    required this.name,
    required this.type,
    required this.density,
    required this.estimatedWaitMinutes,
    this.trend = WaitTrend.stable,
  });

  /// Max wait times by zone type.
  static int maxWaitForType(ZoneType type) {
    switch (type) {
      case ZoneType.gate:
        return 15;
      case ZoneType.foodCourt:
        return 25;
      case ZoneType.restroom:
        return 10;
      default:
        return 5;
    }
  }

  /// Create a QueuePoint from a VenueZone.
  factory QueuePoint.fromZone(VenueZone zone, {WaitTrend trend = WaitTrend.stable}) {
    final maxWait = maxWaitForType(zone.type);
    return QueuePoint(
      zoneId: zone.id,
      name: zone.name,
      type: zone.type,
      density: zone.density,
      estimatedWaitMinutes: (zone.density * maxWait).round(),
      trend: trend,
    );
  }

  String get trendIcon {
    switch (trend) {
      case WaitTrend.increasing:
        return '↑';
      case WaitTrend.decreasing:
        return '↓';
      case WaitTrend.stable:
        return '→';
    }
  }
}

enum WaitTrend { increasing, decreasing, stable }
