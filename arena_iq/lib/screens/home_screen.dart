import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../app_routes.dart';
import '../models/venue_config.dart';
import '../providers/venue_provider.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedVenue = 0;
  bool _isEntering = false;

  final List<VenueConfig> _venues = VenueRegistry.allVenues;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A small hack to dismiss keyboard when tapping outside
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Dark background
            Container(color: AppTheme.bgDark),
            
            // Animated Orbs Backing
            ...List.generate(3, (index) => _AnimatedOrb(index: index)),
            
            // Glass overlay to frost the orbs
            Positioned.fill(
               child: Container(
                  color: AppTheme.bgDark.withOpacity(0.5), // Slightly darker
               )
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'VenueIQ',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: AppTheme.accentCyan,
                              letterSpacing: -1,
                            ),
                      ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Select a live venue',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                      ).animate().fadeIn(delay: 200.ms).slideX(),
                    ),
                    
                    const Spacer(),
                    
                    // 🚀 The Venue Carousel
                    SizedBox(
                      height: 240,
                      child: PageView.builder(
                        controller: PageController(viewportFraction: 0.85),
                        onPageChanged: (idx) => setState(() => _selectedVenue = idx),
                        itemCount: _venues.length,
                        itemBuilder: (context, index) {
                          return _buildVenueCard(_venues[index], index == _selectedVenue);
                        },
                      ),
                    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                    
                    const Spacer(),
                    
                    // 🚀 The Ticket Scanner / Gate Input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.sensor_door, color: AppTheme.accentPurple, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: _venues[_selectedVenue].hintText,
                                      hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.qr_code_scanner, color: AppTheme.textSecondary, size: 20),
                              ],
                            ),
                          ).animate().slideY(begin: 0.2).fadeIn(delay: 600.ms),
                          
                          const SizedBox(height: 24),
                          
                          SizedBox(
                            width: double.infinity,
                            child: GlassButton(
                              onPressed: _isEntering ? () {} : () {
                                 // Trigger entering animation
                                 setState(() => _isEntering = true);
                                 FocusScope.of(context).unfocus();
                                 
                                 // Store selected venue in state provider
                                 final selectedVenue = _venues[_selectedVenue];
                                 context.read<VenueProvider>().setSelectedVenue(selectedVenue);
                                 
                                 Future.delayed(const Duration(milliseconds: 1400), () {
                                    Navigator.pushReplacementNamed(
                                      context, 
                                      AppRoutes.navigation,
                                      arguments: selectedVenue,
                                    );
                                 });
                              },
                              child: _isEntering 
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                                  _venues[_selectedVenue].buttonText,
                                  style: const TextStyle(
                                     color: Colors.white,
                                     fontSize: 18,
                                     fontWeight: FontWeight.bold,
                                     letterSpacing: 1.2
                                  ),
                                ),
                            ),
                          ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Cool entry flash effect
            if (_isEntering)
               Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                       color: AppTheme.accentCyan.withOpacity(0.3),
                    ).animate().fadeIn(duration: 200.ms).then().fadeOut(duration: 800.ms),
                  )
               )
          ],
        ),
      ),
    );
  }

  Widget _buildVenueCard(VenueConfig venue, bool isSelected) {
     final Color typeColor = _getTagColor(venue.type);
     return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(
           right: 16,
           // Make unselected cards slightly recede
           top: isSelected ? 0 : 20,
           bottom: isSelected ? 0 : 20,
        ),
        child: GlassCard(
           // Highlight current selection
           color: isSelected ? typeColor.withOpacity(0.1) : AppTheme.glassWhite.withOpacity(0.05),
           padding: const EdgeInsets.all(24),
           child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                   children: [
                     Icon(venue.icon, size: 36, color: Colors.white),
                     const Spacer(),
                     Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                           color: typeColor.withOpacity(0.2),
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: typeColor),
                        ),
                        child: Text(
                          _getTagText(venue.type),
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                     ),
                   ],
                 ),
                 const Spacer(),
                 Text(venue.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 4),
                 Text(venue.subtitle, style: const TextStyle(color: AppTheme.accentPurple, fontSize: 14)),
                 const SizedBox(height: 16),
                 Row(
                    children: [
                       const Icon(Icons.people, color: AppTheme.textSecondary, size: 14),
                       const SizedBox(width: 4),
                       Text('Capacity: ${venue.capacity}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ]
                 )
              ]
           )
        )
     );
  }

  Color _getTagColor(VenueType type) {
     switch (type) {
       case VenueType.stadium:
         return AppTheme.accentCyan;
       case VenueType.mall:
         return AppTheme.accentYellow;
       case VenueType.railwayStation:
         return AppTheme.accentPurple;
     }
  }

  String _getTagText(VenueType type) {
     switch (type) {
       case VenueType.stadium:
         return 'STADIUM';
       case VenueType.mall:
         return 'MALL';
       case VenueType.railwayStation:
         return 'RAILWAY STATION';
     }
  }
}

class _AnimatedOrb extends StatefulWidget {
  final int index;
  const _AnimatedOrb({required this.index});

  @override
  State<_AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<_AnimatedOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rnd = Random();
  late Color _color;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 10 + _rnd.nextInt(5)))..repeat(reverse: true);
    
    List<Color> colors = [AppTheme.accentCyan, AppTheme.accentPurple, AppTheme.accentGreen];
    _color = colors[widget.index % colors.length];
  }
  
  @override
  void dispose() {
     _controller.dispose();
     super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
         return Positioned(
           top: MediaQuery.of(context).size.height * (0.2 + (_rnd.nextDouble() * 0.1 * widget.index)) + (sin(_controller.value * pi) * 100),
           left: MediaQuery.of(context).size.width * (0.1 + (0.3 * widget.index)) + (cos(_controller.value * pi) * 50),
           child: Container(
              width: 150 + (_rnd.nextDouble() * 100),
              height: 150 + (_rnd.nextDouble() * 100),
              decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: _color.withOpacity(0.05 + (_controller.value * 0.05)),
                 boxShadow: [
                   BoxShadow(
                     color: _color.withOpacity(0.2),
                     blurRadius: 100,
                     spreadRadius: 50,
                   )
                 ]
              ),
           ),
         );
      }
    );
  }
}
