import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/supabase_config.dart';
import '../models/venue_zone.dart';
import '../models/group_member.dart';
import '../models/smart_alert.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  bool _isOnline = false;

  bool get isReady => _client != null && SupabaseConfig.isConfigured;
  bool get isOnline => _isOnline && isReady;

  /// Initializes Supabase and sets up connectivity listening.
  Future<void> init() async {
    if (!SupabaseConfig.isConfigured) {
      print('Supabase not configured. Running in offline mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      await _checkConnectivity();

      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
         _isOnline = !results.contains(ConnectivityResult.none);
      });
      print('Supabase initialized successfully.');
    } catch (e) {
      print('Failed to init Supabase: $e');
    }
  }

  Future<void> _checkConnectivity() async {
     final result = await Connectivity().checkConnectivity();
     _isOnline = !result.contains(ConnectivityResult.none);
  }

  // --- CRUD Helpers (Silently fail if offline/not configured) ---

  Future<void> updateZoneDensity(String zoneId, double density) async {
    if (!isOnline) return;
    try {
      await _client!.from('venue_zones').update({'density': density}).eq('id', zoneId);
    } catch (e) {
      print('Error updating zone density: $e');
    }
  }

  Future<void> upsertGroupMember(GroupMember member, String groupCode) async {
    if (!isOnline) return;
    try {
      final data = member.toJson();
      data['group_code'] = groupCode;
      await _client!.from('group_members').upsert(data);
    } catch (e) {
       print('Error upserting member: $e');
    }
  }

  Future<void> setMeetPoint(String groupCode, int x, int y, String setBy) async {
    if (!isOnline) return;
    try {
      await _client!.from('meet_points').upsert({
         'group_code': groupCode,
         'grid_x': x,
         'grid_y': y,
         'set_by': setBy,
      }, onConflict: 'group_code');
    } catch (e) {
       print('Error setting meet point: $e');
    }
  }
  
  Future<void> insertAlert(SmartAlert alert) async {
     if (!isOnline) return;
     try {
       await _client!.from('smart_alerts').insert(alert.toJson());
     } catch (e) {
        print('Error inserting alert: $e');
     }
  }
}
