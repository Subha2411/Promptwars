import 'dart:async';
import 'dart:math';
import '../models/venue_zone.dart';

class CrowdSimulator {
  Timer? _timer;
  int _tick = 0;
  final Random _random = Random();
  final Function(List<VenueZone>) onUpdate;

  CrowdSimulator({required this.onUpdate});

  /// Starts the density simulation. Updates trigger every 3 seconds.
  void start(List<VenueZone> zones) {
    _timer?.cancel();
    _tick = 0;
    
    // Initial random assignment
    for (var zone in zones) {
       _simulateZone(zone, _tick);
    }
    onUpdate(zones);
    
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _tick++;
      for (var zone in zones) {
         _simulateZone(zone, _tick);
      }
      onUpdate(zones);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _simulateZone(VenueZone zone, int tick) {
    if (!zone.isWalkable) {
       zone.updateDensity(0.0);
       return;
    }

    // Base wave pattern based on tick and zone seed
    double wave = sin(tick * 0.1 + zone.seed) * 0.3;
    
    // Random jitter
    double jitter = (_random.nextDouble() * 0.15) - 0.075;
    
    // Type-specific modifiers to simulate real crowd behavior
    double typeModifier = 0.0;
    switch (zone.type) {
      case ZoneType.gate:
        // Spikes at start and end of event
        typeModifier = cos(tick * 0.05) * 0.2; 
        break;
      case ZoneType.foodCourt:
        // Spikes in the middle
        typeModifier = sin(tick * 0.05) * 0.25 + 0.2;
        break;
      case ZoneType.restroom:
        // Periodic short spikes
        typeModifier = sin(tick * 0.2) > 0.8 ? 0.4 : 0.0;
        break;
      case ZoneType.exit:
        typeModifier = -cos(tick * 0.05) * 0.3;
        break;
      case ZoneType.seating:
        // Generally fills up and stays filled
        typeModifier = 0.4;
        break;
      case ZoneType.corridor:
        typeModifier = 0.1;
        break;
      case ZoneType.field:
        typeModifier = -1.0;
        break;
    }
    
    // Base density anchor is around 0.4
    double newDensity = 0.4 + wave + jitter + typeModifier;
    zone.updateDensity(newDensity);
  }
}
