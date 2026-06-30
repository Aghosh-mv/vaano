import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Vaanologo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool hasBackground;

  const Vaanologo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.hasBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoH = size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: logoH,
          height: logoH,
          child: CustomPaint(
            painter: _VaanologoPainter(),
            size: Size(logoH, logoH),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 2),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFF2D06B),
                Color(0xFFD4A537),
                Color(0xFFF2D06B),
                Color(0xFFB8860B),
              ],
              stops: [0.0, 0.3, 0.6, 1.0],
            ).createShader(bounds),
            child: Text(
              'VAÀNO',
              style: TextStyle(
                fontSize: size * 0.28,
                fontWeight: FontWeight.bold,
                letterSpacing: size * 0.06,
                color: Colors.white,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _VaanologoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h * 0.45;

    final goldLight = const Color(0xFFF2D06B);
    final gold = const Color(0xFFD4A537);
    final goldDark = const Color(0xFFB8860B);

    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Helper to draw a wing feather
    void drawFeather(List<Offset> points) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();
      canvas.drawPath(path, shadow);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [goldLight, gold, goldDark],
          radius: 0.8,
        ).createShader(Rect.fromPoints(points.first, points.last));
      canvas.drawPath(path, paint);
    }

    // Left wing feathers
    drawFeather([
      Offset(cx, cy * 0.25),
      Offset(cx * 0.4, cy * 0.1),
      Offset(cx * 0.1, cy * 0.35),
      Offset(cx * 0.05, cy * 0.5),
      Offset(cx * 0.15, cy * 0.45),
      Offset(cx * 0.4, cy * 0.3),
      Offset(cx * 0.7, cy * 0.4),
    ]);

    drawFeather([
      Offset(cx, cy * 0.42),
      Offset(cx * 0.35, cy * 0.35),
      Offset(cx * 0.1, cy * 0.55),
      Offset(cx * 0.05, cy * 0.7),
      Offset(cx * 0.15, cy * 0.65),
      Offset(cx * 0.35, cy * 0.5),
      Offset(cx * 0.7, cy * 0.55),
    ]);

    drawFeather([
      Offset(cx, cy * 0.6),
      Offset(cx * 0.35, cy * 0.55),
      Offset(cx * 0.1, cy * 0.78),
      Offset(cx * 0.08, cy * 0.95),
      Offset(cx * 0.2, cy * 0.85),
      Offset(cx * 0.4, cy * 0.65),
      Offset(cx * 0.7, cy * 0.7),
    ]);

    // Right wing feathers
    drawFeather([
      Offset(cx, cy * 0.25),
      Offset(cx * 1.6, cy * 0.1),
      Offset(cx * 1.9, cy * 0.35),
      Offset(cx * 1.95, cy * 0.5),
      Offset(cx * 1.85, cy * 0.45),
      Offset(cx * 1.6, cy * 0.3),
      Offset(cx * 1.3, cy * 0.4),
    ]);

    drawFeather([
      Offset(cx, cy * 0.42),
      Offset(cx * 1.65, cy * 0.35),
      Offset(cx * 1.9, cy * 0.55),
      Offset(cx * 1.95, cy * 0.7),
      Offset(cx * 1.85, cy * 0.65),
      Offset(cx * 1.65, cy * 0.5),
      Offset(cx * 1.3, cy * 0.55),
    ]);

    drawFeather([
      Offset(cx, cy * 0.6),
      Offset(cx * 1.65, cy * 0.55),
      Offset(cx * 1.9, cy * 0.78),
      Offset(cx * 1.92, cy * 0.95),
      Offset(cx * 1.8, cy * 0.85),
      Offset(cx * 1.6, cy * 0.65),
      Offset(cx * 1.3, cy * 0.7),
    ]);

    // Draw V body
    final vPaint = Paint()
      ..shader = LinearGradient(
        colors: [goldLight, gold, goldDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, cy * 0.3, w, cy * 0.7));

    final vPath = Path()
      ..moveTo(cx + 2, cy * 0.3)
      ..lineTo(cx * 1.35, h * 0.85)
      ..lineTo(cx * 1.2, h * 0.85)
      ..lineTo(cx + 2, cy * 0.45)
      ..lineTo(cx - 2, cy * 0.45)
      ..lineTo(cx * 0.8, h * 0.85)
      ..lineTo(cx * 0.65, h * 0.85)
      ..lineTo(cx - 2, cy * 0.3)
      ..close();
    canvas.drawPath(vPath, shadow);
    canvas.drawPath(vPath, vPaint);

    // Crown
    final crownPaint = Paint()
      ..shader = LinearGradient(
        colors: [goldLight, gold, goldDark],
      ).createShader(Rect.fromLTWH(cx - 8, cy * 0.22, 16, 10));

    final crownPath = Path()
      ..moveTo(cx - 8, cy * 0.22 + 8)
      ..lineTo(cx - 8, cy * 0.22 + 2)
      ..lineTo(cx - 5, cy * 0.22 + 5)
      ..lineTo(cx, cy * 0.22)
      ..lineTo(cx + 5, cy * 0.22 + 5)
      ..lineTo(cx + 8, cy * 0.22 + 2)
      ..lineTo(cx + 8, cy * 0.22 + 8)
      ..close();
    canvas.drawPath(crownPath, shadow);
    canvas.drawPath(crownPath, crownPaint);

    // Crown jewels
    final jewelPaint = Paint()..color = const Color(0xFFE0115F);
    canvas.drawCircle(Offset(cx - 3, cy * 0.22 + 6), 1.0, jewelPaint);
    canvas.drawCircle(Offset(cx + 3, cy * 0.22 + 6), 1.0, jewelPaint);
    jewelPaint.color = const Color(0xFF00BFFF);
    canvas.drawCircle(Offset(cx, cy * 0.22 + 6), 1.0, jewelPaint);

    // Divider line
    final divPaint = Paint()
      ..color = gold
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx * 0.4, h * 0.92), Offset(cx * 0.45, h * 0.92), divPaint);
    canvas.drawLine(Offset(cx * 0.55, h * 0.92), Offset(cx * 1.6, h * 0.92), divPaint);

    // Diamond star
    final starPaint = Paint()..shader = RadialGradient(
      colors: [goldLight, gold],
    ).createShader(Rect.fromCircle(center: Offset(cx, h * 0.92), radius: 3));
    final starPath = Path()
      ..moveTo(cx, h * 0.92 - 2.5)
      ..lineTo(cx + 1.5, h * 0.92)
      ..lineTo(cx, h * 0.92 + 2.5)
      ..lineTo(cx - 1.5, h * 0.92)
      ..close();
    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
