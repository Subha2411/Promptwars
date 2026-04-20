import 'package:flutter/foundation.dart';
import '../models/smart_alert.dart';
import '../services/alert_engine.dart';
import '../services/supabase_service.dart';
import 'venue_provider.dart';

class AlertProvider extends ChangeNotifier {
  final VenueProvider venueProvider;
  final SupabaseService _supabase = SupabaseService();
  
  final List<SmartAlert> _alerts = [];
  List<SmartAlert> get activeAlerts => _alerts.where((a) => a.isActive).toList();

  AlertProvider(this.venueProvider) {
    venueProvider.addListener(_evaluateLocalAlerts);
  }

  void _evaluateLocalAlerts() {
    // Only run expensive alert eval periodically
    final newAlerts = AlertEngine.generateAlerts(venueProvider.zones);
    
    bool added = false;
    for (var alert in newAlerts) {
      // Very basic dedup: Don't show same message type if we already have it active
      if (!_alerts.any((a) => a.isActive && a.alertType == alert.alertType)) {
         _alerts.insert(0, alert);
         added = true;
         _supabase.insertAlert(alert); // Sync if online
      }
    }
    
    // Auto-dismiss after 15s (demo purposes)
    for (var a in _alerts.where((a) => a.isActive)) {
       if (DateTime.now().difference(a.createdAt).inSeconds > 15) {
          a.isActive = false;
          added = true; // trigger update
       }
    }

    if (added) notifyListeners();
  }

  /// Called by RealtimeSyncService when Supabase pushes a new alert
  void addRemoteAlert(Map<String, dynamic> record) {
      final remoteAlert = SmartAlert.fromJson(record);
      // Dedup check by ID
      if (!_alerts.any((a) => a.id == remoteAlert.id)) {
         _alerts.insert(0, remoteAlert);
         notifyListeners();
      }
  }

  void dismissAlert(String id) {
     final idx = _alerts.indexWhere((a) => a.id == id);
     if (idx != -1) {
       _alerts[idx].isActive = false;
       notifyListeners();
     }
  }

  @override
  void dispose() {
    venueProvider.removeListener(_evaluateLocalAlerts);
    super.dispose();
  }
}
