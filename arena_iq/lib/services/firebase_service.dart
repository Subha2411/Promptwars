import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import '../config/firebase_config.dart';
import '../models/group_member.dart';
import '../models/smart_alert.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore? _db;
  bool _isOnline = false;

  bool get isReady => _db != null && FirebaseConfig.isConfigured;
  bool get isOnline => _isOnline && isReady;

  /// Initializes Firebase and sets up connectivity listening.
  Future<void> init() async {
    if (!FirebaseConfig.isConfigured) {
      print('Firebase not configured. Running in offline mode.');
      return;
    }

    try {
      await Firebase.initializeApp(
        options: FirebaseConfig.currentPlatform,
      );
      _db = FirebaseFirestore.instance;
      await _checkConnectivity();

      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
        _isOnline = !results.contains(ConnectivityResult.none);
      });
      print('Firebase initialized successfully.');
    } catch (e) {
      print('Failed to init Firebase: $e');
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
      await _db!.collection('venue_zones').doc(zoneId).set({
        'id': zoneId,
        'density': density,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating zone density: $e');
    }
  }

  Future<void> upsertGroupMember(GroupMember member, String groupCode) async {
    if (!isOnline) return;
    try {
      final data = member.toJson();
      data['group_code'] = groupCode;
      await _db!.collection('group_members').doc(member.id).set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error upserting member: $e');
    }
  }

  Future<void> setMeetPoint(String groupCode, int x, int y, String setBy) async {
    if (!isOnline) return;
    try {
      await _db!.collection('meet_points').doc(groupCode).set({
        'group_code': groupCode,
        'grid_x': x,
        'grid_y': y,
        'set_by': setBy,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error setting meet point: $e');
    }
  }

  Future<void> insertAlert(SmartAlert alert) async {
    if (!isOnline) return;
    try {
      await _db!.collection('smart_alerts').doc(alert.id).set(alert.toJson());
    } catch (e) {
      print('Error inserting alert: $e');
    }
  }
}
