import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/venue_provider.dart';
import '../app_theme.dart';

class ConnectionStatusBadge extends StatelessWidget {
  const ConnectionStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.select((VenueProvider p) => p.isOnline);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
               color: isOnline ? AppTheme.accentGreen : AppTheme.accentYellow,
               shape: BoxShape.circle,
               boxShadow: [
                  BoxShadow(
                    color: (isOnline ? AppTheme.accentGreen : AppTheme.accentYellow).withOpacity(0.5),
                    blurRadius: 4,
                  )
               ]
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Live' : 'Local Mode',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}
