import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/group_member.dart';
import '../models/route_step.dart';
import '../utils/constants.dart';
import '../services/firebase_service.dart';

class GroupProvider extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  
  String _groupCode = 'HACK26';
  List<GroupMember> _members = [];
  RouteStep? _meetPoint;
  
  Timer? _localSimTimer;
  final Random _rnd = Random();

  String get groupCode => _groupCode;
  List<GroupMember> get members => _members;
  RouteStep? get meetPoint => _meetPoint;

  GroupProvider() {
     _initSimulatedFriends();
  }

  void _initSimulatedFriends() {
    _members = [
      GroupMember(id: 'friend_1', name: 'Arjun', avatarColor: const Color(0xFF00E5FF), gridX: 3, gridY: 2, isSimulated: true),
      GroupMember(id: 'friend_2', name: 'Priya', avatarColor: const Color(0xFFB388FF), gridX: 7, gridY: 5, isSimulated: true),
      GroupMember(id: 'friend_3', name: 'Rahul', avatarColor: const Color(0xFFFFD740), gridX: 1, gridY: 7, isSimulated: true),
    ];
    
    // Simulate walking around locally
    _localSimTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
       bool changed = false;
       for (var m in _members) {
          if (m.isSimulated && (!m.isAtMeetPoint)) {
             // Move 1 step randomly
             int dx = _rnd.nextInt(3) - 1;
             int dy = _rnd.nextInt(3) - 1;
             int newX = (m.gridX + dx).clamp(0, VenueLayout.gridWidth - 1);
             int newY = (m.gridY + dy).clamp(0, VenueLayout.gridHeight - 1);
             
             // Very rough check for walkable in sim (avoiding field in middle)
             if (!(newY == 4 && newX >= 3 && newX <= 6)) {
                 m.gridX = newX;
                 m.gridY = newY;
                 changed = true;
                 
                  // Update firebase if online
                  _firebase.upsertGroupMember(m, _groupCode);
             }
          }
       }
       if (changed) notifyListeners();
    });
  }

  void setMeetPoint(int x, int y) {
     _meetPoint = RouteStep(gridX: x, gridY: y);
     notifyListeners();
     _firebase.setMeetPoint(_groupCode, x, y, 'You');
  }

  /// Called by RealtimeSyncService when Supabase pushes a member change
  void syncFromRemote(Map<String, dynamic> record) {
      if (record['group_code'] != _groupCode) return;
      
      final remoteMember = GroupMember.fromJson(record);
      final idx = _members.indexWhere((m) => m.id == remoteMember.id);
      
      if (idx != -1) {
         _members[idx] = remoteMember;
      } else {
         _members.add(remoteMember);
      }
      notifyListeners();
  }

  /// Called by RealtimeSyncService when Supabase pushes a meet point change
  void updateMeetPoint(Map<String, dynamic> record) {
     if (record['group_code'] != _groupCode) return;
     _meetPoint = RouteStep(gridX: record['grid_x'], gridY: record['grid_y']);
     notifyListeners();
  }

  @override
  void dispose() {
    _localSimTimer?.cancel();
    super.dispose();
  }
}
