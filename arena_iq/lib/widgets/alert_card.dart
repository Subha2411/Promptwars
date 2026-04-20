import 'package:flutter/material.dart';
import '../models/smart_alert.dart';
import '../app_theme.dart';
import 'glass_card.dart';

class AlertCard extends StatelessWidget {
  final SmartAlert alert;
  final VoidCallback? onDismiss;

  const AlertCard({super.key, required this.alert, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    Color accentColor = AppTheme.accentCyan;
    if (alert.severity == AlertSeverity.warning) accentColor = AppTheme.accentYellow;
    if (alert.severity == AlertSeverity.critical) accentColor = AppTheme.accentRed;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      width: 280, // Fixed width for horizontal scrolling
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(alert.icon, style: const TextStyle(fontSize: 16)),
              ),
              const Spacer(),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: const Icon(Icons.close, color: AppTheme.textSecondary, size: 16),
                )
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              alert.message,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTimeago(alert.createdAt),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          )
        ],
      ),
    );
  }

  String _formatTimeago(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
