import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/group_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String navigation = '/navigation';
  static const String queue = '/queue';
  static const String group = '/group';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const HomeScreen(),
        dashboard: (context) => const DashboardScreen(),
        navigation: (context) => const NavigationScreen(),
        queue: (context) => const QueueScreen(),
        group: (context) => const GroupScreen(),
      };
}
