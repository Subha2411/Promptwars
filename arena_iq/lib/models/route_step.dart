/// A single step in a navigation route through the venue.
class RouteStep {
  final int gridX;
  final int gridY;
  final double density;

  const RouteStep({
    required this.gridX,
    required this.gridY,
    this.density = 0.0,
  });
}

/// A complete navigation route with metadata.
class NavigationRoute {
  final List<RouteStep> steps;
  final String destinationName;
  final double totalCost;
  final int estimatedWalkMinutes;
  final double destinationDensity;

  const NavigationRoute({
    required this.steps,
    required this.destinationName,
    required this.totalCost,
    required this.estimatedWalkMinutes,
    required this.destinationDensity,
  });

  bool get isEmpty => steps.isEmpty;

  /// Estimated walk time: ~30 seconds per grid cell.
  static int calculateWalkTime(int stepCount) {
    return ((stepCount * 30) / 60).ceil(); // minutes
  }
}
