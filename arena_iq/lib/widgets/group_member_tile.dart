import 'package:flutter/material.dart';
import '../models/group_member.dart';
import '../app_theme.dart';

class GroupMemberTile extends StatelessWidget {
  final GroupMember member;
  final String locationText;
  final VoidCallback? onLocate;

  const GroupMemberTile({
    super.key,
    required this.member,
    required this.locationText,
    this.onLocate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.glassBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: member.avatarColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: member.avatarColor, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              member.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: member.avatarColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.isAtMeetPoint ? 'Reached meet point' : locationText,
                  style: TextStyle(
                    color: member.isAtMeetPoint ? AppTheme.accentGreen : AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (onLocate != null)
            IconButton(
              icon: const Icon(Icons.my_location, color: AppTheme.accentCyan, size: 20),
              onPressed: onLocate,
            )
        ],
      ),
    );
  }
}
