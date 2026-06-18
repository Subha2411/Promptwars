import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/group_provider.dart';
import '../providers/venue_provider.dart';
import '../models/venue_config.dart';
import '../providers/navigation_provider.dart';
import '../app_theme.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/venue_heatmap.dart';
import '../widgets/pulsing_dot.dart';
import '../widgets/group_member_tile.dart';
import '../widgets/glass_button.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VenueConfig? venue = context.watch<VenueProvider>().selectedVenue;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: venue != null ? 'Group Radar - ${venue.name}' : 'Group Radar',
      ),
      body: Stack(
        children: [
          Container(color: AppTheme.bgDark),
          
          SafeArea(
            child: Consumer2<GroupProvider, VenueProvider>(
              builder: (context, groupProv, venueProv, _) {
                 return Column(
                   children: [
                      // Map View specific to group
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 250,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.glassBorder),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                               children: [
                                  VenueHeatmap(
                                    zones: venueProv.zones,
                                    onZoneTap: (zone) {
                                       groupProv.setMeetPoint(zone.gridX, zone.gridY);
                                    },
                                    overlay: _buildMemberOverlay(groupProv, context),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                       decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(8),
                                       ),
                                       child: const Text('Tap map to set meet point', style: TextStyle(color: Colors.white, fontSize: 10)),
                                    ),
                                  )
                               ]
                            ),
                          ),
                        ),
                      ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
                      
                      const SizedBox(height: 16),
                      
                      // Shared Code Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                           children: [
                              Text('Group: ${groupProv.groupCode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary)),
                              const Spacer(),
                              const Icon(Icons.share, color: AppTheme.accentCyan, size: 20),
                           ]
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Member List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: groupProv.members.length,
                          itemBuilder: (context, index) {
                             final member = groupProv.members[index];
                             final zone = venueProv.getZoneByCoords(member.gridX, member.gridY);
                             return GroupMemberTile(
                                member: member,
                                locationText: zone?.name ?? "Moving...",
                             ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX();
                          }
                        ),
                      ),
                      
                      if (groupProv.meetPoint != null) ...[
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                           child: SizedBox(
                             width: double.infinity,
                             child: GlassButton(
                               onPressed: () {
                                  context.read<NavigationProvider>().setUserPosition(5, 7); // Demo fixed user start
                                  context.read<NavigationProvider>().setDestinationPoint(groupProv.meetPoint!.gridX, groupProv.meetPoint!.gridY);
                                  Navigator.pushReplacementNamed(context, '/navigation');
                               },
                               child: const Text('Navigate to Meet Point', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                             ),
                           ),
                         ).animate().slideY(begin: 1.0)
                      ],
                      
                      const SizedBox(height: 100), // Bottom nav space
                   ],
                 );
              }
            ),
          ),

          // Bottom Navigation
           const Align(
            alignment: Alignment.bottomCenter,
            child: GlassNavBar(currentIndex: 3),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMemberOverlay(GroupProvider groupProv, BuildContext context) {
      return LayoutBuilder(
         builder: (ctx, constraints) {
           final double cellW = constraints.maxWidth / 10;
           final double cellH = constraints.maxHeight / 8;
           
           return Stack(
             children: [
               if (groupProv.meetPoint != null)
                 Positioned(
                   left: (groupProv.meetPoint!.gridX * cellW) + (cellW / 2) - 15,
                   top: (groupProv.meetPoint!.gridY * cellH) + (cellH / 2) - 15,
                   child: const PulsingDot(color: AppTheme.accentPurple, size: 30),
                 ),
                 
               for (var member in groupProv.members)
                 Positioned(
                   left: (member.gridX * cellW) + (cellW / 2) - 8,
                   top: (member.gridY * cellH) + (cellH / 2) - 8,
                   child: AnimatedContainer(
                     duration: const Duration(seconds: 1),
                     curve: Curves.easeInOut,
                     width: 16,
                     height: 16,
                     decoration: BoxDecoration(
                        color: member.avatarColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                     ),
                   ),
                 )
             ],
           );
         }
      );
  }
}
