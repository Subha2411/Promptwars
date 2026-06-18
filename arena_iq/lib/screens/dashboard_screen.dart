import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/venue_provider.dart';
import '../models/venue_config.dart';
import '../providers/alert_provider.dart';
import '../app_theme.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/venue_heatmap.dart';
import '../widgets/heatmap_legend.dart';
import '../widgets/alert_card.dart';
import '../widgets/connection_status_badge.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final venue = context.watch<VenueProvider>().selectedVenue;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: venue != null ? '${venue.name} Dashboard' : 'Live Dashboard',
        actions: const [ConnectionStatusBadge()],
      ),
      body: Stack(
        children: [
          // Main Heatmap Map
          Consumer<VenueProvider>(
            builder: (context, provider, _) {
              return Positioned.fill(
                child: VenueHeatmap(
                  zones: provider.zones,
                  onZoneTap: (zone) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${zone.name}: ${(zone.density * 100).round()}% full'),
                        backgroundColor: AppTheme.bgGradientStart,
                        duration: const Duration(seconds: 2),
                      )
                    );
                  },
                ),
              );
            }
          ),
          
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                
                // Legend
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: HeatmapLegend(),
                  ),
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 16),
                
                // Alert Feed
                Consumer<AlertProvider>(
                  builder: (context, provider, _) {
                    final alerts = provider.activeAlerts;
                    if (alerts.isEmpty) return const SizedBox.shrink();
                    
                    return SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alerts[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: AlertCard(
                              alert: alert,
                              onDismiss: () => provider.dismissAlert(alert.id),
                            ).animate(key: ValueKey(alert.id)).slideX(begin: 0.2).fadeIn(),
                          );
                        },
                      ),
                    );
                  }
                ),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
          
          // Bottom Navigation
          const Align(
            alignment: Alignment.bottomCenter,
            child: GlassNavBar(currentIndex: 0),
          ).animate().slideY(begin: 1.0).fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}
