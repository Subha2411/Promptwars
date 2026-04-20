import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../app_theme.dart';
import '../app_routes.dart';

class GlassNavBar extends StatelessWidget {
  final int currentIndex;

  const GlassNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.glassWhite.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.glassBorder, width: 0.5),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.3),
             blurRadius: 15,
             offset: const Offset(0, 10),
           )
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.accentCyan,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          useLegacyColorScheme: false,
          onTap: (idx) {
             if (idx == currentIndex) return;
             String route = AppRoutes.dashboard;
             switch (idx) {
               case 0: route = AppRoutes.dashboard; break;
               case 1: route = AppRoutes.navigation; break;
               case 2: route = AppRoutes.queue; break;
               case 3: route = AppRoutes.group; break;
             }
             Navigator.pushReplacementNamed(context, route);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.home_2),
              activeIcon: Icon(Iconsax.home_2, color: AppTheme.accentCyan),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.route_square),
              activeIcon: Icon(Iconsax.route_square, color: AppTheme.accentCyan),
              label: 'Navigate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.timer_1),
              activeIcon: Icon(Iconsax.timer_1, color: AppTheme.accentCyan),
              label: 'Queues',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.people),
              activeIcon: Icon(Iconsax.people, color: AppTheme.accentCyan),
              label: 'Group',
            ),
          ],
        ),
      ),
    );
  }
}
