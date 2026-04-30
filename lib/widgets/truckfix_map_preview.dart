import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Stylized map block matching FleetApp / MechanicApp MapPreview.
class TruckFixMapPreview extends StatelessWidget {
  const TruckFixMapPreview({super.key, this.height = 160, this.showRoute = false, this.liveLabel = true});

  final double height;
  final bool showRoute;
  final bool liveLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(color: const Color(0xFF0D1520)),
            CustomPaint(
              size: Size.infinite,
              painter: _GridPainter(),
            ),
            CustomPaint(
              size: Size.infinite,
              painter: _RoadPainter(showRoute: showRoute, h: height),
            ),
            Positioned(
              bottom: 8,
              left: 12,
              child: Text('TruckFix Maps', style: TextStyle(color: Colors.grey[700], fontSize: 10, fontWeight: FontWeight.w500)),
            ),
            if (liveLabel)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: const Text('LIVE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF1A2535);
    const s = 28.0;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoadPainter extends CustomPainter {
  _RoadPainter({required this.h, required this.showRoute});
  final double h;
  final bool showRoute;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.5;
    final path = Path()
      ..moveTo(0, y)
      ..quadraticBezierTo(size.width * 0.33, y - 20, size.width * 0.5, y)
      ..quadraticBezierTo(size.width * 0.67, y + 20, size.width, y);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1E3A4F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF264A5E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    if (showRoute) {
      canvas.drawPath(
        Path()
          ..moveTo(size.width * 0.2, size.height * 0.65)
          ..quadraticBezierTo(size.width * 0.5, size.height * 0.25, size.width * 0.8, size.height * 0.6),
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(Offset(size.width * 0.31, y), 9, Paint()..color = AppColors.primary);
    canvas.drawCircle(Offset(size.width * 0.31, y), 4, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(size.width * 0.72, y - 4), 8, Paint()..color = AppColors.red);
    canvas.drawCircle(Offset(size.width * 0.72, y - 4), 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) =>
      oldDelegate.h != h || oldDelegate.showRoute != showRoute;
}
