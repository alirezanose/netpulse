import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SpeedometerGauge extends StatelessWidget {
  final double speedMbps;
  final double maxSpeed;
  final String statusText;

  const SpeedometerGauge({
    super.key,
    required this.speedMbps,
    this.maxSpeed = 100.0,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      height: 230,
      child: CustomPaint(
        painter: _WhiteAlbumGaugePainter(
          speed: speedMbps,
          maxSpeed: maxSpeed,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text(
              speedMbps.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -1.5,
              ),
            ),
            const Text(
              'MBPS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                statusText.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteAlbumGaugePainter extends CustomPainter {
  final double speed;
  final double maxSpeed;

  _WhiteAlbumGaugePainter({required this.speed, required this.maxSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 12);
    final radius = size.width / 2 - 20;

    // 240 degree clean arc from 150 to 390 degrees
    const startAngle = 150 * (math.pi / 180);
    const sweepAngle = 240 * (math.pi / 180);

    // 1. Minimalist Background Track
    final bgPaint = Paint()
      ..color = AppTheme.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // 2. Active Progress Arc in Matte Black
    final progress = (speed / maxSpeed).clamp(0.0, 1.0);
    final activeSweep = sweepAngle * progress;

    if (activeSweep > 0) {
      final activePaint = Paint()
        ..color = AppTheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        activePaint,
      );

      // Pointer Dot
      final pointerAngle = startAngle + activeSweep;
      final pointerX = center.dx + radius * math.cos(pointerAngle);
      final pointerY = center.dy + radius * math.sin(pointerAngle);

      final dotBg = Paint()..color = AppTheme.surface;
      canvas.drawCircle(Offset(pointerX, pointerY), 7, dotBg);

      final dotCenter = Paint()..color = AppTheme.primary;
      canvas.drawCircle(Offset(pointerX, pointerY), 4, dotCenter);
    }

    // 3. Subtle minimalist ticks
    final tickPaint = Paint()
      ..color = AppTheme.borderDark
      ..strokeWidth = 1.5;

    const int tickCount = 8;
    for (int i = 0; i <= tickCount; i++) {
      final angle = startAngle + (sweepAngle * (i / tickCount));
      final innerX = center.dx + (radius - 14) * math.cos(angle);
      final innerY = center.dy + (radius - 14) * math.sin(angle);
      final outerX = center.dx + (radius - 8) * math.cos(angle);
      final outerY = center.dy + (radius - 8) * math.sin(angle);

      canvas.drawLine(Offset(innerX, innerY), Offset(outerX, outerY), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WhiteAlbumGaugePainter oldDelegate) {
    return oldDelegate.speed != speed || oldDelegate.maxSpeed != maxSpeed;
  }
}
