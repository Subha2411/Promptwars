import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/venue_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/venue_zone.dart';
import '../models/venue_config.dart';
import '../app_theme.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/venue_heatmap.dart';
import '../widgets/route_overlay.dart';
import '../widgets/glass_card.dart';
import '../widgets/pulsing_dot.dart';
import '../utils/constants.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  void initState() {
    super.initState();
    // Default user start pos: East Entrance corridor
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<NavigationProvider>().setUserPosition(5, 7);
    });
  }

  @override
  Widget build(BuildContext context) {
    final VenueConfig? venue = context.watch<VenueProvider>().selectedVenue;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: venue != null ? 'Navigation - ${venue.name}' : 'Smart Navigation',
      ),
      body: Stack(
        children: [
          // Map + Overlay
          Consumer2<VenueProvider, NavigationProvider>(
            builder: (context, venueProv, navProv, _) {
              final screenW = MediaQuery.of(context).size.width;
              final screenH = MediaQuery.of(context).size.height;
              // Drive cell size from width → always square cells on any screen
              final double cellSize = screenW / VenueLayout.gridWidth;
              final double mapH = cellSize * VenueLayout.gridHeight;
              // On wide screens, fill the available height for aesthetics
              final double finalH = mapH < screenH ? screenH : mapH;

              return Positioned.fill(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(
                    height: finalH,
                    child: VenueHeatmap(
                      zones: venueProv.zones,
                      overlay: _buildMapOverlay(navProv),
                      onZoneTap: (zone) {
                        if (navProv.selectedDestinationType == null) {
                           navProv.setDestinationPoint(zone.gridX, zone.gridY);
                        } else {
                           navProv.setUserPosition(zone.gridX, zone.gridY);
                        }
                      },
                    ),
                  ),
                ),
              );
            }
          ),

          
          SafeArea(
             child: Column(
               children: [
                 const SizedBox(height: 16),
                 _buildTopChips(context).animate().fadeIn().slideY(begin: -0.2),
                 const Spacer(),
                 _buildRouteInfoCard(context),
                 const SizedBox(height: 100),
               ],
             )
          ),

          // Bottom Navigation
          const Align(
            alignment: Alignment.bottomCenter,
            child: GlassNavBar(currentIndex: 1),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMapOverlay(NavigationProvider navProv) {
      return LayoutBuilder(
         builder: (ctx, constraints) {
           final double cellW = constraints.maxWidth / VenueLayout.gridWidth;
           final double cellH = constraints.maxHeight / VenueLayout.gridHeight;
           
           return Stack(
             children: [
               if (navProv.currentRoute != null)
                 RouteOverlay(route: navProv.currentRoute!),
               
               // User Position
               Positioned(
                 left: (navProv.userX * cellW) + (cellW / 2) - 10,
                 top: (navProv.userY * cellH) + (cellH / 2) - 10,
                 child: const PulsingDot(color: AppTheme.accentCyan, size: 20),
               )
             ],
           );
         }
      );
  }

  Widget _buildTopChips(BuildContext context) {
      final types = [
        ZoneType.gate,
        ZoneType.seating, 
        ZoneType.foodCourt,
        ZoneType.restroom,
        ZoneType.exit,
      ];
      
      return SingleChildScrollView(
         scrollDirection: Axis.horizontal,
         padding: const EdgeInsets.symmetric(horizontal: 16),
         child: Row(
            children: types.map((t) {
               final isSelected = context.watch<NavigationProvider>().selectedDestinationType == t;
               return Padding(
                 padding: const EdgeInsets.only(right: 8.0),
                 child: GestureDetector(
                   onTap: () {
                     context.read<NavigationProvider>().setDestinationType(t);
                   },
                   child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                         color: isSelected ? AppTheme.accentCyan.withOpacity(0.2) : AppTheme.bgDark.withOpacity(0.6),
                         borderRadius: BorderRadius.circular(20),
                         border: Border.all(color: isSelected ? AppTheme.accentCyan : AppTheme.glassBorder),
                      ),
                      child: Text(
                         t.name.toUpperCase(),
                         style: TextStyle(
                            color: isSelected ? AppTheme.accentCyan : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                         )
                      ),
                   ),
                 ),
               );
            }).toList(),
         )
      );
  }

  Widget _buildRouteInfoCard(BuildContext context) {
     final route = context.watch<NavigationProvider>().currentRoute;
     if (route == null || route.isEmpty) {
        return const Padding(
           padding: EdgeInsets.symmetric(horizontal: 16.0),
           child: GlassCard(
             child: Text('Tap a chip above to find the fastest route around the crowds, or tap anywhere on the map to set a custom destination.', style: TextStyle(color: AppTheme.textSecondary))),
        ).animate().fadeIn();
     }
     
     return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GlassCard(
           child: Row(
              children: [
                 const Icon(Icons.directions_walk, color: AppTheme.accentCyan, size: 32),
                 const SizedBox(width: 16),
                 Expanded(
                    child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Text('Routing to ${route.destinationName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Density-optimized path avoids high traffic', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                       ],
                    )
                 ),
                 Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text('${route.estimatedWalkMinutes} min', style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold, fontSize: 20)),
                       const Text('walk time', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                    ],
                 )
              ]
           )
        ),
     ).animate(key: ValueKey(route.destinationName)).slideY(begin: 0.2).fadeIn();
  }
}
