import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../viewmodel/fleet_viewmodel.dart';

/// Full-screen fleet notifications overlay (matches fleet dashboard black bg).
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
  static const Color _bgBlack = Color(0xFF000000);

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
        leading: _notifLeadingGrey(Icons.description_outlined),
      ),
      _NotifRowModel(
        headline: 'Quote Accepted',
        detail: 'You accepted the quote. Waiting for mechanic to start journey',
        when: '1 hr ago',
        unread: true,
        leading: _notifLeadingSolid(AppColors.green, Icons.check_rounded),
      ),
      _NotifRowModel(
        headline: 'Mechanic Started Journey',
        detail: 'Deon is on the way to your vehicle, ETA 15 min',
        when: '1 hr ago',
        unread: false,
        leading: _notifLeadingSolid(AppColors.red, Icons.directions_car_rounded),
      ),
      _NotifRowModel(
        headline: 'Job Completed',
        detail: 'Please approve completion for TF-8801',
        when: '2 hrs ago',
        unread: false,
        leading: _notifLeadingSolid(AppColors.green, Icons.check_rounded),
      ),
      _NotifRowModel(
        headline: 'Payment Processed',
        detail: '£145.00 charged to card ending 4242',
        when: '3 hrs ago',
        unread: false,
        leading: _notifLeadingSolid(AppColors.orange, Icons.credit_card_rounded),
      ),
      _NotifRowModel(
        headline: 'Review Reminder',
        detail: 'Rate your experience with Sipho Molefe',
        when: '5 hrs ago',
        unread: false,
        leading: _notifLeadingSolid(AppColors.primary, Icons.star_rounded),
      ),
    ];
  }

  int get _unreadCount => _rows.where((r) => r.unread).length;

  static Widget _notifLeadingGrey(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 24),
    );
  }

  static Widget _notifLeadingSolid(Color bg, IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white, size: 24),
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
        color: _bgBlack,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                        onTap: vm.closeNotifications,
                        //customBorder: const CircleBorder(),
                        child:  Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFF262626),
                          ),
                          width: 44,
                          height: 40,
                          child: Icon(Icons.arrow_back, color: Colors.white, size: 18),
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
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _unreadCount == 0 ? 'All caught up' : '$_unreadCount unread',
                              style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'MARK ALL READ',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.4),
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
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, thickness: 1, color: Colors.white.withValues(alpha: 0.06)),
                  itemBuilder: (context, i) {
                    final r = _rows[i];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (!r.unread) return;
                          setState(() => r.unread = false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              r.leading,
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.headline,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      r.detail,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.72),
                                        fontSize: 13,
                                        height: 1.35,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      r.when,
                                      style: const TextStyle(
                                          color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (r.unread)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration:
                                        const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
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
