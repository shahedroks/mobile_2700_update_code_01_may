import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.onNavigate});

  final void Function(String) onNavigate;

  /// Screenshot reference: vibrant yellow (~#FFCC00), black, white.
  static const Color _kAccentYellow = Color(0xFFFFCC00);
  static const Color _kWrench = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _kAccentYellow.withValues(alpha: 0.06),
                    const Color(0xFF000000),
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: CustomPaint(
              painter: _SplashDiagonalStripesPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            clipBehavior: Clip.antiAlias,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _kAccentYellow,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: _kAccentYellow.withValues(alpha: 0.45),
                                  blurRadius: 28,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Transform.translate(
                              offset: const Offset(-1.0, -1.5),
                              child: Transform.rotate(
                                angle: -math.pi / -2,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.build_outlined,
                                  size: 48,
                                  color: _kWrench,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text.rich(
                              textAlign: TextAlign.center,
                              TextSpan(
                                style: const TextStyle(
                                  fontSize: 46,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                  height: 1.05,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'TRUCK',
                                    style: TextStyle(color: Color(0xFFFFFFFF)),
                                  ),
                                  TextSpan(
                                    text: 'FIX',
                                    style: TextStyle(color: _kAccentYellow),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: _kAccentYellow,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: _kAccentYellow,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: _kAccentYellow,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Find repair and maintenance support when your vehicle needs it.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => onNavigate('role-select-signup'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kAccentYellow,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: _kAccentYellow.withValues(alpha: 0.35),
                            ),
                            child: const Text(
                              'GET STARTED →',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.6,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFFFFFF),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => onNavigate('role-select'),
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              color: Color(0xFFFFFFFF),
                            ),
                            children: [
                              const TextSpan(text: 'Continue to login as '),
                              TextSpan(
                                text: 'Fleet / Mechanic',
                                style: const TextStyle(
                                  color: _kAccentYellow,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashDiagonalStripesPainter extends CustomPainter {
  const _SplashDiagonalStripesPainter();

  static const Color _stripe = Color(0xFFFFCC00);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _stripe.withValues(alpha: 0.08)
      ..strokeWidth = 1
      ..isAntiAlias = true;

    const double spacing = 8;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
