import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/queue_provider.dart';
import '../providers/venue_provider.dart';
import '../models/venue_config.dart';
import '../models/venue_zone.dart';
import '../app_theme.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/queue_card.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VenueConfig? venue = context.watch<VenueProvider>().selectedVenue;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: venue != null ? 'Queue Insights - ${venue.name}' : 'Queue Insights',
      ),
      body: Stack(
        children: [
          // Background 
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.bgDark, AppTheme.bgGradientEnd],
              )
            ),
          ),
          
          SafeArea(
            child: Consumer<QueueProvider>(
              builder: (context, provider, _) {
                 if (provider.queuePoints.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan));
                 }
                 
                 return CustomScrollView(
                   slivers: [
                     _buildSectionTitle('Gates'),
                     _buildList(provider, ZoneType.gate),
                     
                     _buildSectionTitle('Food Courts'),
                     _buildList(provider, ZoneType.foodCourt),
                     
                     _buildSectionTitle('Restrooms'),
                     _buildList(provider, ZoneType.restroom),
                     
                     const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom nav space
                   ],
                 );
              }
            ),
          ),

          // Bottom Navigation
          const Align(
            alignment: Alignment.bottomCenter,
            child: GlassNavBar(currentIndex: 2),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
     return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
     );
  }
  
  Widget _buildList(QueueProvider provider, ZoneType type) {
     final queues = provider.getQueuesByType(type);
     return SliverList(
       delegate: SliverChildBuilderDelegate(
         (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: QueueCard(queue: queues[index])
                 .animate(key: ValueKey(queues[index].zoneId))
                 .fadeIn(delay: Duration(milliseconds: 100 * index))
                 .slideX(begin: -0.1),
            );
         },
         childCount: queues.length,
       ),
     );
  }
}
