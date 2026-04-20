import 'package:flutter/foundation.dart';
import '../models/queue_point.dart';
import '../models/venue_zone.dart';
import 'venue_provider.dart';

class QueueProvider extends ChangeNotifier {
  final VenueProvider venueProvider;
  
  List<QueuePoint> _queuePoints = [];
  List<QueuePoint> get queuePoints => _queuePoints;

  QueueProvider(this.venueProvider) {
    _updateQueues();
    venueProvider.addListener(_updateQueues);
  }

  void _updateQueues() {
    final validTypes = [ZoneType.gate, ZoneType.foodCourt, ZoneType.restroom];
    
    _queuePoints = venueProvider.zones
        .where((z) => validTypes.contains(z.type))
        .map((z) {
          // Calculate generic trend for UI
          WaitTrend trend = WaitTrend.stable;
          if (z.density > z.previousDensity + 0.05) trend = WaitTrend.increasing;
          if (z.density < z.previousDensity - 0.05) trend = WaitTrend.decreasing;
          
          return QueuePoint.fromZone(z, trend: trend);
        })
        .toList();

    notifyListeners();
  }

  List<QueuePoint> getQueuesByType(ZoneType type) {
    return _queuePoints.where((q) => q.type == type).toList()
      ..sort((a,b) => a.estimatedWaitMinutes.compareTo(b.estimatedWaitMinutes));
  }

  @override
  void dispose() {
    venueProvider.removeListener(_updateQueues);
    super.dispose();
  }
}
