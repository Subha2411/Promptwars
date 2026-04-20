import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/route_step.dart';
import '../utils/constants.dart';
import '../app_theme.dart';

class RouteOverlay extends StatefulWidget {
  final NavigationRoute route;

  const RouteOverlay({super.key, required this.route});

  @override
  State<RouteOverlay> createState() => _RouteOverlayState();
}

class _RouteOverlayState extends State<RouteOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(RouteOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route != widget.route) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.route.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _RoutePainter(route: widget.route, progress: _controller.value),
        );
      },
    );
  }
}

class _RoutePainter extends CustomPainter {
  final NavigationRoute route;
  final double progress;

  _RoutePainter({required this.route, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (route.isEmpty) return;

    final double cellW = size.width / VenueLayout.gridWidth;
    final double cellH = size.height / VenueLayout.gridHeight;

    final Path fullPath = Path();
    
    // Start point
    final startPt = Offset(
      (route.steps[0].gridX * cellW) + (cellW / 2),
      (route.steps[0].gridY * cellH) + (cellH / 2),
    );
    fullPath.moveTo(startPt.dx, startPt.dy);

    for (int i = 1; i < route.steps.length; i++) {
       final pt = Offset(
         (route.steps[i].gridX * cellW) + (cellW / 2),
         (route.steps[i].gridY * cellH) + (cellH / 2),
       );
       fullPath.lineTo(pt.dx, pt.dy);
    }

    // Extract path based on progress safely
    try {
        final pathMetrics = fullPath.computeMetrics().toList();
        if (pathMetrics.isNotEmpty) {
           final double totalLength = pathMetrics.fold(0.0, (prev, metric) => prev + metric.length);
           final double currentLength = totalLength * progress;

           Path extractedPath = Path();
           double distance = 0.0;

           for (var metric in pathMetrics) {
             final double metricLength = metric.length;
             if (distance + metricLength > currentLength) {
               extractedPath.addPath(
                 metric.extractPath(0, currentLength - distance),
                 Offset.zero,
               );
               break;
             } else {
               extractedPath.addPath(metric.extractPath(0, metricLength), Offset.zero);
               distance += metricLength;
             }
           }

           // Draw the path glow
           canvas.drawPath(
             extractedPath,
             Paint()
               ..color = AppTheme.accentCyan.withOpacity(0.4)
               ..style = PaintingStyle.stroke
               ..strokeCap = StrokeCap.round
               ..strokeJoin = StrokeJoin.round
               ..strokeWidth = 8.0
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
           );

           // Draw the solid path line (dashed effect is complex with custom paint extraction, keeping it solid with dropshadow for now for performance)
           canvas.drawPath(
             extractedPath,
             Paint()
               ..color = AppTheme.accentCyan
               ..style = PaintingStyle.stroke
               ..strokeCap = StrokeCap.round
               ..strokeJoin = StrokeJoin.round
               ..strokeWidth = 3.0,
           );
        }
    } catch (_) {}

    // Draw end marker if finished drawing
    if (progress > 0.95) {
       final endPt = Offset(
         (route.steps.last.gridX * cellW) + (cellW / 2),
         (route.steps.last.gridY * cellH) + (cellH / 2),
       );
       
       canvas.drawCircle(
          endPt, 
          8.0, 
          Paint()..color = AppTheme.bgDark
       );
       canvas.drawCircle(
          endPt, 
          6.0, 
          Paint()..color = AppTheme.accentCyan
       );
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.route != route;
  }
}
