import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class RealtimeSyncService {
  final FirebaseService _firebaseService;

  RealtimeSyncService(this._firebaseService);

  StreamSubscription? _zonesSub;
  StreamSubscription? _membersSub;
  StreamSubscription? _alertsSub;
  StreamSubscription? _meetPointsSub;

  /// Starts listening to Cloud Firestore collection updates.
  void startSubscriptions({
    required Function(Map<String, dynamic>) onZoneUpdate,
    required Function(Map<String, dynamic>) onMemberUpdate,
    required Function(Map<String, dynamic>) onAlertInsert,
    required Function(Map<String, dynamic>) onMeetPointUpdate,
  }) {
    if (!_firebaseService.isReady) return;

    final db = FirebaseFirestore.instance;

    // Listen to venue_zones updates
    _zonesSub = db.collection('venue_zones').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data != null) {
            onZoneUpdate(data);
          }
        }
      }
    }, onError: (e) => print('Error in venue_zones stream: $e'));

    // Listen to group_members updates
    _membersSub = db.collection('group_members').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data != null) {
          onMemberUpdate(data);
        }
      }
    }, onError: (e) => print('Error in group_members stream: $e'));

    // Listen to smart_alerts (only new alerts added)
    _alertsSub = db.collection('smart_alerts').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            onAlertInsert(data);
          }
        }
      }
    }, onError: (e) => print('Error in smart_alerts stream: $e'));

    // Listen to meet_points updates
    _meetPointsSub = db.collection('meet_points').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data != null) {
          onMeetPointUpdate(data);
        }
      }
    }, onError: (e) => print('Error in meet_points stream: $e'));
  }

  /// Stops all listeners.
  void stopSubscriptions() {
    _zonesSub?.cancel();
    _membersSub?.cancel();
    _alertsSub?.cancel();
    _meetPointsSub?.cancel();
  }
}
