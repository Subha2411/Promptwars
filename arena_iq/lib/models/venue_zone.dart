/// Types of zones in the venue.
enum ZoneType {
  gate,
  seating,
  foodCourt,
  restroom,
  exit,
  corridor,
  field,
}

/// A single zone/cell in the venue grid.
class VenueZone {
  final String id;
  final String name;
  final ZoneType type;
  final int gridX;
  final int gridY;
  double density; // 0.0 (empty) to 1.0 (packed)
  bool isWalkable;
  double _previousDensity;
  double seed; // For simulation wave patterns

  VenueZone({
    required this.id,
    required this.name,
    required this.type,
    required this.gridX,
    required this.gridY,
    this.density = 0.0,
    this.isWalkable = true,
    this.seed = 0.0,
  }) : _previousDensity = density;

  double get previousDensity => _previousDensity;

  void updateDensity(double newDensity) {
    _previousDensity = density;
    density = newDensity.clamp(0.0, 1.0);
  }

  /// Density level category.
  DensityLevel get densityLevel {
    if (density < 0.35) return DensityLevel.low;
    if (density < 0.65) return DensityLevel.medium;
    return DensityLevel.high;
  }

  /// Icon label for the zone type.
  String get icon {
    switch (type) {
      case ZoneType.gate:
        return '🚪';
      case ZoneType.seating:
        return '💺';
      case ZoneType.foodCourt:
        return '🍔';
      case ZoneType.restroom:
        return '🚻';
      case ZoneType.exit:
        return '🚶';
      case ZoneType.corridor:
        return '·';
      case ZoneType.field:
        return '⚽';
    }
  }

  /// Short label for heatmap display.
  String get shortLabel {
    switch (type) {
      case ZoneType.gate:
        return 'G';
      case ZoneType.seating:
        return 'S';
      case ZoneType.foodCourt:
        return 'F';
      case ZoneType.restroom:
        return 'R';
      case ZoneType.exit:
        return 'E';
      case ZoneType.corridor:
        return '';
      case ZoneType.field:
        return '⚽';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'zone_type': type.name,
        'grid_x': gridX,
        'grid_y': gridY,
        'density': density,
        'is_walkable': isWalkable,
      };

  factory VenueZone.fromJson(Map<String, dynamic> json) {
    return VenueZone(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ZoneType.values.firstWhere(
        (e) => e.name == json['zone_type'],
        orElse: () => ZoneType.corridor,
      ),
      gridX: json['grid_x'] as int,
      gridY: json['grid_y'] as int,
      density: (json['density'] as num?)?.toDouble() ?? 0.0,
      isWalkable: json['is_walkable'] as bool? ?? true,
    );
  }
}

enum DensityLevel { low, medium, high }
