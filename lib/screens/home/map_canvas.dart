import 'package:flutter/material.dart';
import 'node_model.dart';

class MapCanvas extends CustomPainter {
  final List<MapNode> nodes;

  MapCanvas(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF637F9F)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < nodes.length - 1; i++) {
      final a = nodes[i];
      final b = nodes[i + 1];

      final start = Offset(a.x * size.width, a.y * size.height);
      final end = Offset(b.x * size.width, b.y * size.height);

      // control point untuk curve
      final control = Offset(
        (start.dx + end.dx) / 2,
        ((start.dy + end.dy) / 2) - 40,
      );

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
