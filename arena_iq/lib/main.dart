import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'app_routes.dart';
import 'providers/venue_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/queue_provider.dart';
import 'providers/group_provider.dart';
import 'providers/alert_provider.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase. If credentials aren't set, it fails gracefully and app runs offline-first
  await FirebaseService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VenueProvider()),
        ChangeNotifierProxyProvider<VenueProvider, NavigationProvider>(
          create: (context) => NavigationProvider(context.read<VenueProvider>()),
          update: (context, venue, previous) => previous ?? NavigationProvider(venue),
        ),
        ChangeNotifierProxyProvider<VenueProvider, QueueProvider>(
          create: (context) => QueueProvider(context.read<VenueProvider>()),
          update: (context, venue, previous) => previous ?? QueueProvider(venue),
        ),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProxyProvider<VenueProvider, AlertProvider>(
          create: (context) => AlertProvider(context.read<VenueProvider>()),
          update: (context, venue, previous) => previous ?? AlertProvider(venue),
        ),
      ],
      child: const ArenaIQApp(),
    ),
  );
}

class ArenaIQApp extends StatelessWidget {
  const ArenaIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArenaIQ',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      // Custom page transition logic could go here
    );
  }
}
