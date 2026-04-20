import '../models/venue_zone.dart';
import '../models/smart_alert.dart';
import 'package:uuid/uuid.dart';

class AlertEngine {
  static final _uuid = const Uuid();
  
  /// Evaluates the venue state and generates appropriate smart alerts.
  static List<SmartAlert> generateAlerts(List<VenueZone> zones, {SmartAlert? currentAlert}) {
    List<SmartAlert> generated = [];
    final now = DateTime.now();

    // Group zones by type
    final gates = zones.where((z) => z.type == ZoneType.gate).toList();
    final foodCourts = zones.where((z) => z.type == ZoneType.foodCourt).toList();
    final restrooms = zones.where((z) => z.type == ZoneType.restroom).toList();
    
    // Check Gate crowding
    final packedGates = gates.where((g) => g.density > 0.7).toList();
    final freeGates = gates.where((g) => g.density < 0.4).toList();
    
    if (packedGates.isNotEmpty && freeGates.isNotEmpty) {
       packedGates.sort((a,b) => b.density.compareTo(a.density));
       freeGates.sort((a,b) => a.density.compareTo(b.density));
       
       generated.add(SmartAlert(
         id: _uuid.v4(),
         message: "${packedGates.first.name} is crowded. Try ${freeGates.first.name} instead for faster entry.",
         alertType: AlertType.crowd,
         icon: '🚪',
         severity: AlertSeverity.warning,
       ));
    }
    
    // Check Food waiting
    final busyFood = foodCourts.where((f) => f.density > 0.6).toList();
    final quietFood = foodCourts.where((f) => f.density < 0.35).toList();
    
    if (busyFood.isNotEmpty && quietFood.isNotEmpty) {
       generated.add(SmartAlert(
         id: _uuid.v4(),
         message: "High wait time at ${busyFood.first.name}. ${quietFood.first.name} is currently quiet.",
         alertType: AlertType.food,
         icon: '🍔',
         severity: AlertSeverity.info,
       ));
    }
    
    // Check Restroom queues
    final packedRestrooms = restrooms.where((r) => r.density > 0.8).toList();
    if (packedRestrooms.isNotEmpty) {
        final quietRestroom = restrooms.where((r) => r.density < 0.5).firstOrNull;
        if (quietRestroom != null) {
           generated.add(SmartAlert(
             id: _uuid.v4(),
             message: "${packedRestrooms.first.name} has a long queue. Try ${quietRestroom.name}.",
             alertType: AlertType.restroom,
             icon: '🚻',
             severity: AlertSeverity.warning,
           ));
        }
    }
    
    // General crowd tip
    final avgDensity = zones.fold(0.0, (sum, z) => sum + z.density) / zones.where((z) => z.isWalkable).length;
    if (avgDensity < 0.3) {
        generated.add(SmartAlert(
             id: _uuid.v4(),
             message: "Crowds are thinning! Great time to move around or grab snacks.",
             alertType: AlertType.general,
             icon: '✨',
             severity: AlertSeverity.info,
           ));
    }

    return generated;
  }
}
