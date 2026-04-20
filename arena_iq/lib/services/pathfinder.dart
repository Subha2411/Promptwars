import 'dart:collection';
import '../models/venue_zone.dart';
import '../models/route_step.dart';
import '../utils/constants.dart';

class Pathfinder {
  /// Finds the optimal path from start to a destination type using BFS with density weighting.
  static NavigationRoute findRoute(
      int startX, int startY, ZoneType destType, List<VenueZone> grid) {
    
    // Find all valid destinations
    final destinations = grid.where((z) => z.type == destType).toList();
    if (destinations.isEmpty) return NavigationRoute(steps: [], destinationName: '', totalCost: 0, estimatedWalkMinutes: 0, destinationDensity: 0);

    NavigationRoute? bestRoute;

    for (var dest in destinations) {
      final route = _findPathToTarget(startX, startY, dest.gridX, dest.gridY, grid);
      if (route != null) {
        if (bestRoute == null || route.totalCost < bestRoute.totalCost) {
          bestRoute = route;
        }
      }
    }

    return bestRoute ?? NavigationRoute(steps: [], destinationName: 'No route', totalCost: 0, estimatedWalkMinutes: 0, destinationDensity: 0);
  }
  
  /// Finds optimal path from start to specific end coordinates
  static NavigationRoute? findRouteToPoint(
      int startX, int startY, int endX, int endY, List<VenueZone> grid) {
      return _findPathToTarget(startX, startY, endX, endY, grid);
  }

  static NavigationRoute? _findPathToTarget(
      int startX, int startY, int endX, int endY, List<VenueZone> grid) {
    
    if (startX == endX && startY == endY) return null;

    final width = VenueLayout.gridWidth;
    final height = VenueLayout.gridHeight;
    
    // Quick index helpers
    int idx(int x, int y) => y * width + x;
    bool isValid(int x, int y) => x >= 0 && x < width && y >= 0 && y < height && grid[idx(x, y)].isWalkable;

    // Dijkstra's algorithm structures
    final dist = List<double>.filled(width * height, double.infinity);
    final prev = List<int?>.filled(width * height, null);
    final pq = PriorityQueue<_Node>((a, b) => a.cost.compareTo(b.cost));

    dist[idx(startX, startY)] = 0;
    pq.add(_Node(startX, startY, 0));

    // Directions: Up, Down, Left, Right
    final dx = [0, 0, -1, 1];
    final dy = [-1, 1, 0, 0];

    while (pq.isNotEmpty) {
      final current = pq.removeFirst();
      final u = idx(current.x, current.y);
      
      if (current.x == endX && current.y == endY) break; // Found target
      if (current.cost > dist[u]) continue; // Stale node

      for (int i = 0; i < 4; i++) {
        final nx = current.x + dx[i];
        final ny = current.y + dy[i];

        if (isValid(nx, ny)) {
          final v = idx(nx, ny);
          final zone = grid[v];
          
          // Cost formula: base step (1.0) + penalty for crowd density (up to 3.0)
          final stepCost = 1.0 + (zone.density * 3.0);
          final newCost = dist[u] + stepCost;

          if (newCost < dist[v]) {
            dist[v] = newCost;
            prev[v] = u;
            pq.add(_Node(nx, ny, newCost));
          }
        }
      }
    }

    // Reconstruct path
    int? current = idx(endX, endY);
    if (prev[current] == null) return null; // Unreachable
    
    int endZoneIdx = current;

    List<RouteStep> path = [];
    while (current != null) {
      final x = current % width;
      final y = current ~/ width;
      final zone = grid[current];
      path.insert(0, RouteStep(gridX: x, gridY: y, density: zone.density));
      current = prev[current];
    }

    final destZone = grid[endZoneIdx];
    return NavigationRoute(
      steps: path,
      destinationName: destZone.name,
      totalCost: dist[endZoneIdx],
      estimatedWalkMinutes: NavigationRoute.calculateWalkTime(path.length),
      destinationDensity: destZone.density,
    );
  }
}

class _Node {
  final int x;
  final int y;
  final double cost;
  _Node(this.x, this.y, this.cost);
}

// Simple PQ implementation for Dijkstra
class PriorityQueue<T> {
  final List<T> _items = [];
  final int Function(T, T) _compare;

  PriorityQueue(this._compare);

  void add(T item) {
    _items.add(item);
    _items.sort(_compare);
  }

  T removeFirst() {
    return _items.removeAt(0);
  }

  bool get isNotEmpty => _items.isNotEmpty;
}
