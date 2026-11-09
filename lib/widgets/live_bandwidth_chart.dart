import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LiveBandwidthChart extends StatelessWidget {
  final List<double> speedHistory;
  final double height;

  const LiveBandwidthChart({
    super.key,
    required this.speedHistory,
    this.height = 110,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LIVE BANDWIDTH',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppTheme.textMuted,
                ),
              ),
              Text(
                speedHistory.isEmpty
                    ? '0.0 Mbps'
                    : '${speedHistory.last.toStringAsFixed(1)} Mbps',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: speedHistory.isEmpty
                ? const Center(
                    child: Text(
                      'Waiting for test to start',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  )
                : CustomPaint(
                    size: Size.infinite,
                    painter: _WhiteAlbumChartPainter(data: speedHistory),
                  ),
          ),
        ],
      ),
    );
  }
}

class _WhiteAlbumChartPainter extends CustomPainter {
  final List<double> data;

  _WhiteAlbumChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    double maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal < 10.0) maxVal = 10.0;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxVal) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (data[i - 1] / maxVal) * size.height;
        final controlX1 = prevX + (stepX / 2);
        final controlX2 = prevX + (stepX / 2);
        path.cubicTo(controlX1, prevY, controlX2, y, x, y);
        fillPath.cubicTo(controlX1, prevY, controlX2, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // 1. Subtle Zinc/Charcoal Fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primary.withValues(alpha: 0.08),
          AppTheme.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // 2. Crisp Charcoal Line
    final linePaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _WhiteAlbumChartPainter oldDelegate) => true;
}
