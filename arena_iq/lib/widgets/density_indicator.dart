import 'package:flutter/material.dart';

class DensityIndicator extends StatelessWidget {
  final double density;
  
  const DensityIndicator({super.key, required this.density});

  @override
  Widget build(BuildContext context) {
     Color color = const Color(0xFF69F0AE); // green
     if (density > 0.35) color = const Color(0xFFFFD740); // yellow
     if (density > 0.65) color = const Color(0xFFFF5252); // red
     
     return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
               color: color.withOpacity(0.5),
               blurRadius: 4,
            )
          ]
        ),
     );
  }
}
