import 'dart:ui';

/// A member of the user's group inside the venue.
class GroupMember {
  final String id;
  final String name;
  final Color avatarColor;
  int gridX;
  int gridY;
  bool isSimulated;
  bool isAtMeetPoint;
  String? currentZoneName;

  GroupMember({
    required this.id,
    required this.name,
    required this.avatarColor,
    this.gridX = 0,
    this.gridY = 0,
    this.isSimulated = false,
    this.isAtMeetPoint = false,
    this.currentZoneName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar_color': '#${avatarColor.value.toRadixString(16).padLeft(8, '0')}',
        'grid_x': gridX,
        'grid_y': gridY,
        'is_simulated': isSimulated,
        'is_at_meet_point': isAtMeetPoint,
      };

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    final colorStr = (json['avatar_color'] as String?) ?? '#FF00E5FF';
    final colorValue = int.parse(colorStr.replaceFirst('#', ''), radix: 16);
    return GroupMember(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarColor: Color(colorValue),
      gridX: json['grid_x'] as int? ?? 0,
      gridY: json['grid_y'] as int? ?? 0,
      isSimulated: json['is_simulated'] as bool? ?? false,
      isAtMeetPoint: json['is_at_meet_point'] as bool? ?? false,
    );
  }
}
