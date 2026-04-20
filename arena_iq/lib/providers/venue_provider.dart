import 'package:flutter/foundation.dart';
import '../models/venue_zone.dart';
import '../utils/constants.dart';
import '../services/crowd_simulator.dart';
import '../services/supabase_service.dart';
import '../services/realtime_sync_service.dart';

class VenueProvider extends ChangeNotifier {
  List<VenueZone> _zones = [];
  CrowdSimulator? _simulator;
  final SupabaseService _supabase = SupabaseService();
  RealtimeSyncService? _syncService;
  
  bool _isOnline = false;

  List<VenueZone> get zones => _zones;
  bool get isOnline => _isOnline;

  VenueProvider() {
    _zones = VenueLayout.getInitialZones();
    _checkConnectivityAndInit();
  }

  void _checkConnectivityAndInit() {
    _isOnline = _supabase.isOnline;
    
    if (_isOnline) {
      _initOnlineSync();
    } else {
      _initLocalSimulation();
    }
    
    // In a real app we'd listen to connectivity changes here and swap modes.
  }

  void _initLocalSimulation() {
    _simulator?.stop();
    _simulator = CrowdSimulator(onUpdate: (updatedZones) {
       _zones = updatedZones;
       notifyListeners();
    });
    _simulator!.start(_zones);
  }

  void _initOnlineSync() {
    // If online AND configured, we act as both the simulator writer AND reader for the demo.
    // In production, the backend handles simulation.
    _simulator?.stop();
    _simulator = CrowdSimulator(onUpdate: (updatedZones) {
       _zones = updatedZones;
       notifyListeners();
       // Push changes to supabase
       for (var z in updatedZones) {
          _supabase.updateZoneDensity(z.id, z.density);
       }
    });
    _simulator!.start(_zones);

    _syncService = RealtimeSyncService(_supabase);
    _syncService!.startSubscriptions(
       onZoneUpdate: _handleRemoteZoneUpdate,
       onMemberUpdate: (_) {}, // Handled by GroupProv
       onAlertInsert: (_) {},  // Handled by AlertProv
       onMeetPointUpdate: (_) {}, // Handled by GroupProv
    );
  }

  void _handleRemoteZoneUpdate(Map<String, dynamic> record) {
     final id = record['id'] as String;
     final density = (record['density'] as num).toDouble();
     
     final idx = _zones.indexWhere((z) => z.id == id);
     if (idx != -1) {
        _zones[idx].updateDensity(density);
        notifyListeners();
     }
  }

  VenueZone? getZoneByCoords(int x, int y) {
    try {
      return _zones.firstWhere((z) => z.gridX == x && z.gridY == y);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _simulator?.stop();
    _syncService?.stopSubscriptions();
    super.dispose();
  }
}
