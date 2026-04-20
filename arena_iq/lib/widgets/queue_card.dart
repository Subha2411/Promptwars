import 'package:flutter/material.dart';
import '../models/queue_point.dart';
import '../models/venue_zone.dart';
import '../app_theme.dart';
import 'glass_card.dart';

class QueueCard extends StatelessWidget {
  final QueuePoint queue;
  final VoidCallback? onTap;

  const QueueCard({super.key, required this.queue, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Determine color based on wait time relative to max
    final maxWait = QueuePoint.maxWaitForType(queue.type);
    final ratio = queue.estimatedWaitMinutes / maxWait;
    
    Color statusColor = AppTheme.accentGreen;
    if (ratio > 0.4) statusColor = AppTheme.accentYellow;
    if (ratio > 0.75) statusColor = AppTheme.accentRed;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(
                  _getIcon(queue.type),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    queue.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        queue.trendIcon,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTrendText(queue.trend),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                     // In a real app we'd use the AnimatedCounter widget here
                    Text(
                      '${queue.estimatedWaitMinutes}',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      ' min',
                      style: TextStyle(
                        color: statusColor.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'est. wait',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _getIcon(ZoneType type) {
     switch (type) {
       case ZoneType.gate: return '🚪';
       case ZoneType.foodCourt: return '🍔';
       case ZoneType.restroom: return '🚻';
       default: return '📍';
     }
  }

  String _getTrendText(WaitTrend trend) {
     switch (trend) {
       case WaitTrend.increasing: return 'Wait is increasing';
       case WaitTrend.decreasing: return 'Wait is decreasing';
       case WaitTrend.stable: return 'Stable queue';
     }
  }
}
