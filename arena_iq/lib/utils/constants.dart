import '../models/venue_zone.dart';

class VenueLayout {
  static const int gridWidth = 10;
  static const int gridHeight = 8;

  /// Defines the initial layout of the venue grid.
  static List<VenueZone> getInitialZones() {
    final zones = <VenueZone>[];

    // Initialize all as corridors
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        zones.add(VenueZone(
          id: 'z_${x}_$y',
          name: 'Corridor',
          type: ZoneType.corridor,
          gridX: x,
          gridY: y,
          seed: (x * 3.14) + (y * 2.71), // For wave simulation
        ));
      }
    }

    // Helper to override a zone
    void setZone(int x, int y, String id, String name, ZoneType type, {bool isWalkable = true}) {
      final index = y * gridWidth + x;
      zones[index] = VenueZone(
        id: id,
        name: name,
        type: type,
        gridX: x,
        gridY: y,
        isWalkable: isWalkable,
        seed: (x * 3.14) + (y * 2.71),
      );
    }

    // Row 0: Gates
    setZone(0, 0, 'gate_1', 'Gate 1', ZoneType.gate);
    setZone(3, 0, 'gate_2', 'Gate 2', ZoneType.gate);
    setZone(6, 0, 'gate_3', 'Gate 3', ZoneType.gate);
    setZone(9, 0, 'gate_4', 'Gate 4', ZoneType.gate);

    // Row 1 & 7: Food Courts (and Exits on row 7)
    setZone(1, 1, 'food_1', 'Food Court North', ZoneType.foodCourt);
    setZone(8, 1, 'food_2', 'Food Court East', ZoneType.foodCourt);
    setZone(1, 7, 'food_3', 'Food Court South', ZoneType.foodCourt);
    setZone(8, 7, 'food_4', 'Food Court West', ZoneType.foodCourt);
    
    setZone(4, 7, 'exit_1', 'West Exit', ZoneType.exit);
    setZone(5, 7, 'exit_2', 'East Exit', ZoneType.exit);

    // Row 2 & 6: Restrooms
    setZone(0, 2, 'restroom_1', 'Restroom A', ZoneType.restroom);
    setZone(9, 2, 'restroom_2', 'Restroom B', ZoneType.restroom);
    setZone(0, 6, 'restroom_3', 'Restroom C', ZoneType.restroom);
    setZone(9, 6, 'restroom_4', 'Restroom D', ZoneType.restroom);

    // Row 2, 3, 5, 6: Seating (columns 2-7)
    for (int y in [2, 3, 5, 6]) {
      for (int x = 2; x <= 7; x++) {
        // Skip restroom over-writes
        if ((x == 0 && (y == 2 || y == 6)) || (x == 9 && (y == 2 || y == 6))) continue;
        
        final blockId = String.fromCharCode(65 + y - 2); // roughly A, B, C, D
        setZone(x, y, 'seat_${x}_$y', 'Block $blockId$x', ZoneType.seating);
      }
    }

    // Row 4: Field (non-walkable)
    for (int x = 3; x <= 6; x++) {
      setZone(x, 4, 'field_$x', 'Field', ZoneType.field, isWalkable: false);
    }

    return zones;
  }
}
