import 'package:flutter/material.dart';
import '../models/venue_zone.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';

class VenueHeatmap extends StatefulWidget {
  final List<VenueZone> zones;
  final Function(VenueZone)? onZoneTap;
  final Widget? overlay;

  const VenueHeatmap({
    super.key,
    required this.zones,
    this.onZoneTap,
    this.overlay,
  });

  @override
  State<VenueHeatmap> createState() => _VenueHeatmapState();
}

class _VenueHeatmapState extends State<VenueHeatmap> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cellWidth = constraints.maxWidth / VenueLayout.gridWidth;
        final double cellHeight = constraints.maxHeight / VenueLayout.gridHeight;
        
        return Stack(
          children: [
            GestureDetector(
              onTapUp: (details) {
                if (widget.onZoneTap == null) return;
                
                final int x = (details.localPosition.dx / cellWidth).floor();
                final int y = (details.localPosition.dy / cellHeight).floor();
                
                if (x >= 0 && x < VenueLayout.gridWidth && y >= 0 && y < VenueLayout.gridHeight) {
                   try {
                      final zone = widget.zones.firstWhere((z) => z.gridX == x && z.gridY == y);
                      widget.onZoneTap!(zone);
                   } catch (_) {}
                }
              },
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _HeatmapPainter(zones: widget.zones, context: context),
              ),
            ),
            if (widget.overlay != null)
              Positioned.fill(child: widget.overlay!),
          ],
        );
      },
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final List<VenueZone> zones;
  final BuildContext context;

  _HeatmapPainter({required this.zones, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final double cellW = size.width / VenueLayout.gridWidth;
    final double cellH = size.height / VenueLayout.gridHeight;
    final double padding = 2.0;

    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var zone in zones) {
      final Rect rect = Rect.fromLTWH(
        (zone.gridX * cellW) + padding,
        (zone.gridY * cellH) + padding,
        cellW - (padding * 2),
        cellH - (padding * 2),
      );

      final RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

      // Fill color
      final Paint fillPaint = Paint()..style = PaintingStyle.fill;
      if (!zone.isWalkable) {
        fillPaint.color = Colors.white.withOpacity(0.03); // Field
      } else if (zone.type == ZoneType.corridor) {
        // Corridors get a very subtle tint based on density
        fillPaint.color = zone.densityColor.withOpacity(0.1 + (zone.density * 0.2));
      } else {
        // Actual functional zones get stronger colors
        fillPaint.color = zone.densityColor.withOpacity(0.4 + (zone.density * 0.4));
      }
      
      canvas.drawRRect(rRect, fillPaint);
      canvas.drawRRect(rRect, borderPaint);

      // Draw Icon/Label
      if (zone.shortLabel.isNotEmpty) {
         final TextSpan span = TextSpan(
           text: zone.shortLabel,
           style: TextStyle(
             color: Colors.white.withOpacity(0.8),
             fontSize: 10,
             fontWeight: FontWeight.bold,
           ),
         );
         final TextPainter tp = TextPainter(
           text: span,
           textAlign: TextAlign.center,
           textDirection: TextDirection.ltr,
         );
         tp.layout();
         tp.paint(
           canvas, 
           Offset(rect.center.dx - (tp.width / 2), rect.center.dy - (tp.height / 2))
         );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
     return true; // We want to repaint on density updates
  }
}
