import 'package:flutter/material.dart';

/// Reference palette for this screen only (matches design spec).
abstract final class _PendingPalette {
  static const Color bg = Color(0xFF121212);
  static const Color card = Color(0xFF1C1C1E);
  static const Color accent = Color(0xFFFFCC00);
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyLight = Color(0xFFBDBDBD);
  static const Color greyInactive = Color(0xFF4D4D4D);
  static const Color cardBorder = Color(0xFF2C2C2E);
  static const Color connectorMuted = Color(0xFF3D3D3D);
}

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key, required this.onNavigate});

  final void Function(String) onNavigate;

  static const List<Map<String, dynamic>> steps = [
    {'label': 'Application Submitted', 'sub': 'Received 07 Mar 2026 · 14:32', 'done': true, 'active': false},
    {'label': 'Background Check', 'sub': 'Industry compliance screening', 'done': false, 'active': true},
    {'label': 'Account Activated', 'sub': "We'll notify you once your account is live", 'done': false, 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _PendingPalette.bg,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _PendingPalette.accent.withValues(alpha: 0.06),
              _PendingPalette.bg,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _PendingPalette.accent.withValues(alpha: 0.85), width: 2),
                      ),
                      child: const Icon(Icons.schedule, size: 40, color: _PendingPalette.accent),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: _PendingPalette.accent,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '!',
                          style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900, height: 1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Under Review',
                  style: TextStyle(color: _PendingPalette.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your application is being processed. This typically takes 2-4 business hours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _PendingPalette.greyLight, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _PendingPalette.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _PendingPalette.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VERIFICATION PROGRESS',
                        style: TextStyle(
                          color: _PendingPalette.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...steps.asMap().entries.map((e) {
                        final step = e.value;
                        final isLast = e.key == steps.length - 1;
                        final done = step['done'] == true;
                        final active = step['active'] == true;
                        final vibrant = done || active;
                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: done ? _PendingPalette.accent : Colors.transparent,
                                        border: Border.all(
                                          color: done || active ? _PendingPalette.accent : _PendingPalette.greyInactive,
                                          width: 2,
                                        ),
                                      ),
                                      child: done
                                          ? const Icon(Icons.check, size: 14, color: Colors.black)
                                          : active
                                              ? const Icon(Icons.circle, size: 8, color: _PendingPalette.accent)
                                              : const Icon(Icons.circle, size: 6, color: _PendingPalette.greyInactive),
                                    ),
                                    if (!isLast)
                                      Container(
                                        width: 2,
                                        height: 24,
                                        color: done ? _PendingPalette.accent.withValues(alpha: 0.65) : _PendingPalette.connectorMuted,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          step['label'] as String,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: vibrant ? _PendingPalette.white : _PendingPalette.greyInactive,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          step['sub'] as String,
                                          style: TextStyle(
                                            color: vibrant ? _PendingPalette.greyLight : _PendingPalette.greyInactive,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _PendingPalette.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _PendingPalette.cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _PendingPalette.accent, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '!',
                          style: TextStyle(
                            color: _PendingPalette.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keep an eye on your inbox',
                              style: TextStyle(
                                color: _PendingPalette.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "We'll send your login credentials to the email you provided once approved.",
                              style: TextStyle(
                                color: _PendingPalette.greyLight,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => onNavigate('splash'),
                  child: const Text(
                    '← Return to Home',
                    style: TextStyle(color: _PendingPalette.greyLight, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
