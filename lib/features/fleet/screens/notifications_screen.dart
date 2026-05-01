import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../viewmodel/fleet_viewmodel.dart';

/// Fleet notifications (`NotificationsScreen` / fleet reference UI).
class FleetNotificationsOverlay extends StatefulWidget {
  const FleetNotificationsOverlay({super.key});

  @override
  State<FleetNotificationsOverlay> createState() => _FleetNotificationsOverlayState();
}

class _NotifRowModel {
  _NotifRowModel({
    required this.headline,
    required this.detail,
    required this.when,
    required this.unread,
    required this.leading,
  });

  final String headline;
  final String detail;
  final String when;
  bool unread;
  final Widget leading;
}

class _FleetNotificationsOverlayState extends State<FleetNotificationsOverlay> {
  /// Main screen background (very dark brown-black).
  static const Color _bg = Color(0xFF0A0A05);
  /// Unread row highlight.
  static const Color _unreadRowBg = Color(0xFF14140D);
  static const Color _divider = Color(0xFF252520);
  static const Color _bodyMuted = Color(0xFFA8A29E);
  static const Color _quotePurple = Color(0xFF6366F1);

  late final List<_NotifRowModel> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      _NotifRowModel(
        headline: 'New Quote Received',
        detail: 'Deon van Wyk quoted £145 for TF-8821',
        when: '2 min ago',
        unread: true,
        leading: _leadingSolid(_quotePurple, Icons.payments_rounded),
      ),
      _NotifRowModel(
        headline: 'Quote Accepted',
        detail: 'You accepted the quote. Waiting for mechanic to start journey',
        when: '1 hr ago',
        unread: true,
        leading: _leadingSolid(AppColors.green, Icons.check_rounded),
      ),
      _NotifRowModel(
        headline: 'Mechanic Started Journey',
        detail: 'Deon is on the way to your vehicle, ETA 15 min',
        when: '1 hr ago',
        unread: false,
        leading: _leadingSolid(AppColors.red, Icons.directions_car_rounded),
      ),
      _NotifRowModel(
        headline: 'Job Completed',
        detail: 'Please approve completion for TF-8801',
        when: '2 hrs ago',
        unread: false,
        leading: _leadingSolid(AppColors.green, Icons.check_rounded),
      ),
    ];
  }

  int get _unreadCount => _rows.where((r) => r.unread).length;

  static Widget _leadingSolid(Color bg, IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  void _markAllRead() {
    setState(() {
      for (final r in _rows) {
        r.unread = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FleetViewModel>();

    return Positioned.fill(
      child: Material(
        color: _bg,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: const Color(0xFF1A1A1A),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: vm.closeNotifications,
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notifications',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _unreadCount == 0 ? 'All caught up' : '$_unreadCount unread',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: TextButton(
                        onPressed: _unreadCount == 0 ? null : _markAllRead,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'MARK ALL READ',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: _rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1, color: _divider),
                  itemBuilder: (context, i) {
                    final r = _rows[i];
                    return Material(
                      color: r.unread ? _unreadRowBg : _bg,
                      child: InkWell(
                        onTap: () {
                          if (!r.unread) return;
                          setState(() => r.unread = false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              r.leading,
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.headline,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      r.detail,
                                      style: const TextStyle(
                                        color: _bodyMuted,
                                        fontSize: 13,
                                        height: 1.4,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      r.when,
                                      style: TextStyle(
                                        color: AppColors.textMuted.withValues(alpha: 0.95),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (r.unread)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
