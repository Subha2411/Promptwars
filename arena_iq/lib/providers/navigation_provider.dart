import 'package:flutter/foundation.dart';
import '../models/venue_zone.dart';
import '../models/route_step.dart';
import '../services/pathfinder.dart';
import 'venue_provider.dart';

class NavigationProvider extends ChangeNotifier {
  final VenueProvider venueProvider;
  
  int _userX = 0;
  int _userY = 0;
  ZoneType? _selectedDestinationType;
  NavigationRoute? _currentRoute;

  NavigationProvider(this.venueProvider) {
    venueProvider.addListener(_onVenueUpdate);
  }

  int get userX => _userX;
  int get userY => _userY;
  ZoneType? get selectedDestinationType => _selectedDestinationType;
  NavigationRoute? get currentRoute => _currentRoute;

  void setUserPosition(int x, int y) {
    _userX = x;
    _userY = y;
    _recalculateRoute();
  }

  void setDestinationType(ZoneType type) {
    _selectedDestinationType = type;
    _recalculateRoute();
  }
  
  void setDestinationPoint(int x, int y) {
      _selectedDestinationType = null;
      _currentRoute = Pathfinder.findRouteToPoint(_userX, _userY, x, y, venueProvider.zones);
      notifyListeners();
  }

  void _onVenueUpdate() {
    if (_selectedDestinationType != null) {
       _recalculateRoute();
    }
  }

  void _recalculateRoute() {
    if (_selectedDestinationType == null) return;

    final newRoute = Pathfinder.findRoute(
        _userX, _userY, _selectedDestinationType!, venueProvider.zones);
        
    // Only notify if route actually changed significantly to avoid jitter
    if (_currentRoute == null || _hasRouteChanged(_currentRoute!, newRoute)) {
       _currentRoute = newRoute;
       notifyListeners();
    }
  }

  bool _hasRouteChanged(NavigationRoute oldRoute, NavigationRoute newRoute) {
     if (oldRoute.steps.length != newRoute.steps.length) return true;
     // If cost changed by more than 20%
     if ((oldRoute.totalCost - newRoute.totalCost).abs() > (oldRoute.totalCost * 0.2)) return true;
     return false;
  }

  @override
  void dispose() {
    venueProvider.removeListener(_onVenueUpdate);
    super.dispose();
  }
}
