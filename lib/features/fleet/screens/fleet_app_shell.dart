import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/fleet_job_summary.dart';
import '../../../data/models/vehicle.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/truckfix_map_preview.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../categories/job_categories.dart';
import '../viewmodel/fleet_viewmodel.dart';
import 'notifications_screen.dart';
import 'post_job_screen.dart';

/// Fleet dashboard reference (#000000 bg, accent yellow/green/red/orange).
abstract final class _FleetDashTheme {
  static const Color bgBlack = Color(0xFF000000);
  static const Color statCardBg = Color(0xFF161616);
  static const Color pillTrackBg = Color(0xFF1F1F1F);
  static const Color yellowBannerSubtitle = Color(0xFF78350F);
  static const Color greenBannerBg = Color(0xFF052E16);
  static const Color greenBannerBorder = Color(0xFF22C55E);
  static const Color blueUrgency = Color(0xFF2563EB);
}

Color _jobCardAccent(FleetJobSummary j) {
  final s = j.status.toUpperCase();
  if (s.contains('AWAIT')) return AppColors.primary;
  if (s.contains('ROUT')) return AppColors.orange;
  if (s.contains('POST')) return AppColors.red;
  if (s.contains('ON SITE')) return AppColors.green;
  switch (j.urgency.toUpperCase()) {
    case 'HIGH':
      return AppColors.orange;
    case 'MEDIUM':
      return AppColors.primary;
    case 'CRITICAL':
      return AppColors.red;
    default:
      return Color(j.urgencyColorHex);
  }
}

(Color bg, Color fg) _urgencyPillStyle(String urgency) {
  switch (urgency.toUpperCase()) {
    case 'HIGH':
      return (AppColors.orange, Colors.white);
    case 'MEDIUM':
      return (_FleetDashTheme.blueUrgency, Colors.white);
    case 'CRITICAL':
      return (AppColors.red, Colors.white);
    default:
      return (AppColors.textMuted, Colors.white);
  }
}

/// Dashboard row data when repo has fewer than four jobs (ids align with merge helper).
const List<FleetJobSummary> _kDashboardDemoJobs = [
  FleetJobSummary(
    id: 'TF-8823',
    truck: 'WC 234-567 • Flatbed',
    issue: 'Brake system repair — awaiting your approval',
    status: 'AWAITING APPROVAL',
    urgency: 'MEDIUM',
    urgencyColorHex: 0xFF2563EB,
    urgencyBgHex: 0x332563EB,
    statusColorHex: 0xFFFBBF24,
    statusBgHex: 0x33FBBF24,
  ),
  FleetJobSummary(
    id: 'TF-8821',
    truck: 'CA 456-789 • Tautliner',
    issue: 'Engine overheating — M1 near Birmingham',
    status: 'EN ROUTE',
    urgency: 'HIGH',
    urgencyColorHex: 0xFFFB923C,
    urgencyBgHex: 0x33FB923C,
    statusColorHex: 0xFFFB923C,
    statusBgHex: 0x33FB923C,
  ),
  FleetJobSummary(
    id: 'TF-8819',
    truck: 'GP 112-334 • Refrigerated',
    issue: 'Hydraulic lift fault — depot standby',
    status: 'POSTED',
    urgency: 'CRITICAL',
    urgencyColorHex: 0xFFEF4444,
    urgencyBgHex: 0x33EF4444,
    statusColorHex: 0xFFEF4444,
    statusBgHex: 0x33EF4444,
  ),
  FleetJobSummary(
    id: 'TF-8809',
    truck: 'LD 882 TF • Tractor',
    issue: 'Scheduled coupling inspection',
    status: 'ON SITE',
    urgency: 'MEDIUM',
    urgencyColorHex: 0xFF2563EB,
    urgencyBgHex: 0x332563EB,
    statusColorHex: 0xFF4ADE80,
    statusBgHex: 0x334ADE80,
  ),
];

List<FleetJobSummary> _dashboardJobsForUi(List<FleetJobSummary> repo) {
  final byId = {for (final j in repo) j.id: j};
  return _kDashboardDemoJobs.map((d) => byId[d.id] ?? d).toList();
}

class FleetAppShell extends StatelessWidget {
  const FleetAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => FleetViewModel(ctx.read<JobRepository>()),
      child: const _FleetScaffold(),
    );
  }
}

class _FleetScaffold extends StatelessWidget {
  const _FleetScaffold();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FleetViewModel>();
    final jobs = context.read<JobRepository>().fleetActiveJobs();

    return Scaffold(
      backgroundColor: _FleetDashTheme.bgBlack,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _FleetBody(jobs: jobs)),
              _FleetBottomNav(vm: vm),
            ],
          ),
          if (vm.showVehicles) _FleetVehiclesOverlay(),
          if (vm.showPaymentMethods) _FleetPaymentOverlay(),
          if (vm.showHelp) _FleetHelpOverlay(),
          if (vm.showNotifications) FleetNotificationsOverlay(),
        ],
      ),
    );
  }
}

class _FleetBody extends StatelessWidget {
  const _FleetBody({required this.jobs});

  final List<FleetJobSummary> jobs;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FleetViewModel>();
    switch (vm.tab) {
      case 'dashboard':
        return _FleetDashboard(
          jobs: jobs,
          onPost: () => vm.setTab('post-job'),
          onTracking: () => vm.setTab('tracking'),
          onOpenNotifications: vm.openNotifications,
        );
      case 'post-job':
        return FleetPostJobScreen(
          profileComplete: vm.profileComplete,
          prefilled: vm.prefilledVehicle?.label,
          onSubmit: () => vm.setTab('tracking'),
          onEditProfile: () => vm.setTab('edit-profile'),
        );
      case 'tracking':
        return _FleetTrackingList(jobs: jobs, onOpenDetail: () => vm.setTab('tracking-detail'));
      case 'tracking-detail':
        return _FleetTrackingDetail(onBack: () => vm.setTab('tracking'));
      case 'quote-received':
        return _FleetQuoteReceived(onDone: () => vm.setTab('tracking'));
      case 'profile':
        return _FleetProfile(
          onEdit: () => vm.setTab('edit-profile'),
          onVehicles: vm.openVehicles,
          onPayment: vm.openPayment,
          onHelp: vm.openHelp,
          onLogout: () async {
            await context.read<AuthViewModel>().logout();
            if (context.mounted) context.go(AppRoutes.login);
          },
        );
      case 'edit-profile':
        return _FleetEditProfile(
          onSave: vm.markProfileComplete,
          onCancel: () => vm.setTab('profile'),
        );
      case 'vehicle-detail':
        final v = vm.selectedVehicle;
        if (v == null) {
          return _FleetDashboard(
            jobs: jobs,
            onPost: () => vm.setTab('post-job'),
            onTracking: () => vm.setTab('tracking'),
            onOpenNotifications: vm.openNotifications,
          );
        }
        return _FleetVehicleDetail(
          vehicle: v,
          onBack: vm.clearSelectedVehicle,
          onRequest: () => vm.requestServiceFromVehicle(v),
        );
      default:
        return _FleetDashboard(
          jobs: jobs,
          onPost: () => vm.setTab('post-job'),
          onTracking: () => vm.setTab('tracking'),
          onOpenNotifications: vm.openNotifications,
        );
    }
  }
}

class _FleetBottomNav extends StatelessWidget {
  const _FleetBottomNav({required this.vm});

  final FleetViewModel vm;

  @override
  Widget build(BuildContext context) {
    final active = vm.bottomNavActive;

    Widget iconFor(String id, bool on) {
      switch (id) {
        case 'dashboard':
          return Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: on ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.grid_view_rounded, size: 20, color: on ? Colors.black : AppColors.textMuted),
          );
        case 'post-job':
          if (on) {
            return Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Icons.add, size: 22, color: Colors.black),
            );
          }
          return Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textMuted, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.add, size: 16, color: AppColors.textMuted),
          );
        case 'tracking':
          return Icon(Icons.navigation_rounded, size: 24, color: on ? AppColors.primary : AppColors.textMuted);
        case 'profile':
          return Icon(Icons.person_outline_rounded, size: 24, color: on ? AppColors.primary : AppColors.textMuted);
        default:
          return Icon(Icons.circle_outlined, size: 24, color: AppColors.textMuted);
      }
    }

    Widget item(String id, String label) {
      final on = active == id;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => vm.setTab(id),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconFor(id, on),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: on ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _FleetDashTheme.bgBlack.withValues(alpha: 0.94),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            item('dashboard', 'Dashboard'),
            item('post-job', 'Post Job'),
            item('tracking', 'Tracking'),
            item('profile', 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _FleetDashboard extends StatefulWidget {
  const _FleetDashboard({
    required this.jobs,
    required this.onPost,
    required this.onTracking,
    required this.onOpenNotifications,
  });

  final List<FleetJobSummary> jobs;
  final VoidCallback onPost;
  final VoidCallback onTracking;
  final VoidCallback onOpenNotifications;

  @override
  State<_FleetDashboard> createState() => _FleetDashboardState();
}

class _FleetDashboardState extends State<_FleetDashboard> {
  bool _showActiveJobs = true;

  @override
  Widget build(BuildContext context) {
    const companyName = 'Logistix Transport';
    final displayJobs = _dashboardJobsForUi(widget.jobs);
    final listJobs = _showActiveJobs ? displayJobs : const <FleetJobSummary>[];

    PreferredSizeWidget dashboardAppBar() {
      return PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: _FleetDashTheme.bgBlack,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 88,
          flexibleSpace: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GOOD MORNING',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          companyName,
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.1),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        onTap: widget.onOpenNotifications,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF262626),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                      Positioned(
                        right: 9,
                        top: 9,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration:  BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.center,
                    child: const Text(
                      'LT',
                      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget statChip({
      required IconData icon,
      required Color accent,
      required String value,
      required String caption,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          decoration: BoxDecoration(
            color: _FleetDashTheme.statCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(color: accent, fontSize: 22, fontWeight: FontWeight.w900, height: 1),
              ),
              const SizedBox(height: 6),
              Text(
                caption,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6),
              ),
            ],
          ),
        ),
      );
    }

    Widget marchSpendCard() {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'March Spend',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Text(
                  '£4,250',
                  style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: 0.64,
                  backgroundColor: const Color(0xFF2A2A2A),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '64% of monthly budget (£6,500)',
              style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.9), fontSize: 11, height: 1.3),
            ),
          ],
        ),
      );
    }

    Widget jobCard(FleetJobSummary j) {
      final accent = _jobCardAccent(j);
      final pill = _urgencyPillStyle(j.urgency);
      final pillBg = pill.$1;
      final pillFg = pill.$2;
      final showEta = j.status.toUpperCase().contains('ROUT');
      final posted = j.status.toUpperCase().contains('POST');
      final mechanicLabel = posted ? 'Awaiting mechanic...' : 'James M.';
      final statusColor = Color(j.statusColorHex);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTracking,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: accent),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  j.id,
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: pillBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    j.urgency,
                                    style: TextStyle(color: pillFg, fontSize: 9, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              j.truck,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              j.issue,
                              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.35, fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.handyman_outlined, size: 14, color: AppColors.textMuted),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          mechanicLabel,
                                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      j.status,
                                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                                    ),
                                    if (showEta) ...[
                                      const SizedBox(width: 10),
                                      Text(
                                        'ETA 18 min',
                                        style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                    const SizedBox(width: 4),
                                    Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted.withValues(alpha: 0.7)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _FleetDashTheme.bgBlack,
      appBar: dashboardAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Row(
            children: [
              statChip(icon: Icons.bolt_rounded, accent: AppColors.primary, value: '3', caption: 'ACTIVE'),
              const SizedBox(width: 10),
              statChip(icon: Icons.warning_amber_rounded, accent: AppColors.red, value: '1', caption: 'AWAITING'),
              const SizedBox(width: 10),
              statChip(icon: Icons.check_circle_outline_rounded, accent: AppColors.green, value: '14', caption: 'THIS MONTH'),
            ],
          ),
          const SizedBox(height: 18),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: widget.onTracking,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: _FleetDashTheme.greenBannerBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _FleetDashTheme.greenBannerBorder, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration:  BoxDecoration(
                          color: _FleetDashTheme.greenBannerBorder,
                          borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.check_circle_outline_outlined, color: Colors.black, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Job Awaiting Approval',
                            style: TextStyle(color: _FleetDashTheme.greenBannerBorder, fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap to review & release payment.',
                            style: TextStyle(color: Color(0xFF86EFAC), fontSize: 12, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: _FleetDashTheme.greenBannerBorder.withValues(alpha: 0.85), size: 22),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: widget.onPost,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration:  BoxDecoration(
                          color: Colors.black87, borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.add_circle, color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Post a Breakdown Job',
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Get mechanics responding in minutes',
                            style: TextStyle(color: _FleetDashTheme.yellowBannerSubtitle, fontSize: 12, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.black.withValues(alpha: 0.65), size: 22),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _FleetDashTheme.pillTrackBg,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showActiveJobs = true),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _showActiveJobs ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    color: _showActiveJobs ? Colors.black : AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _showActiveJobs ? Colors.black.withValues(alpha: 0.12) : const Color(0xFF333333),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    '4',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: _showActiveJobs ? Colors.black : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showActiveJobs = false),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_showActiveJobs ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'COMPLETED',
                                  style: TextStyle(
                                    color: !_showActiveJobs ? Colors.black : AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: !_showActiveJobs ? Colors.black.withValues(alpha: 0.12) : const Color(0xFF333333),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    '5',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: !_showActiveJobs ? Colors.black : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: widget.onTracking,
                style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: const EdgeInsets.only(left: 10)),
                child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_showActiveJobs) ...listJobs.map(jobCard),
          if (!_showActiveJobs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No completed jobs yet.',
                  style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.85), fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 8),
          marchSpendCard(),
        ],
      ),
    );
  }
}

class _FleetTrackingList extends StatelessWidget {
  const _FleetTrackingList({required this.jobs, required this.onOpenDetail});

  final List<FleetJobSummary> jobs;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Tracking', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        const TruckFixMapPreview(height: 180, showRoute: true),
        const SizedBox(height: 20),
        ...jobs.map(
          (j) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: onOpenDetail,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(j.id, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    Text(j.truck, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    Text(j.status, style: TextStyle(color: Color(j.statusColorHex), fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FleetTrackingDetail extends StatelessWidget {
  const _FleetTrackingDetail({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary)),
            const Text('Job detail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        const SizedBox(height: 8),
        const TruckFixMapPreview(height: 200, showRoute: true),
        const SizedBox(height: 16),
        const Text('Status timeline', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        ...['Job posted', 'Mechanic assigned', 'En route', 'On site', 'Completed'].map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check_circle, color: AppColors.green, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(s, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
            ]),
          ),
        ),
      ],
    );
  }
}

class _FleetQuoteReceived extends StatelessWidget {
  const _FleetQuoteReceived({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final quotes = context.read<JobRepository>().postedQuotes();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('New quotes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        ...quotes.map(
          (q) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(imageUrl: q.imageUrl, width: 48, height: 48, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        Text(q.total, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ElevatedButton(onPressed: onDone, child: const Text('Back to tracking')),
      ],
    );
  }
}

class _FleetProfile extends StatelessWidget {
  const _FleetProfile({
    required this.onEdit,
    required this.onVehicles,
    required this.onPayment,
    required this.onHelp,
    required this.onLogout,
  });

  final VoidCallback onEdit;
  final VoidCallback onVehicles;
  final VoidCallback onPayment;
  final VoidCallback onHelp;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.card2,
              backgroundImage: CachedNetworkImageProvider(AppAssets.mechanicPortrait),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Logistix Transport', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  Text('Fleet operator', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 24),
        _tile(Icons.directions_car_outlined, 'Vehicles', onVehicles),
        _tile(Icons.credit_card, 'Payment methods', onPayment),
        _tile(Icons.help_outline, 'Help & support', onHelp),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout, color: AppColors.red),
          label: const Text('Log out', style: TextStyle(color: AppColors.red)),
        ),
      ],
    );
  }

  Widget _tile(IconData i, String t, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: onTap,
          leading: Icon(i, color: AppColors.primary),
          title: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _FleetEditProfile extends StatelessWidget {
  const _FleetEditProfile({required this.onSave, required this.onCancel});

  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(onPressed: onCancel, icon: const Icon(Icons.close, color: AppColors.textSecondary)),
            const Text('Edit profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        const SizedBox(height: 16),
        const TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(labelText: 'COMPANY NAME'),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onSave, child: const Text('Save')),
      ],
    );
  }
}

class _FleetVehicleDetail extends StatelessWidget {
  const _FleetVehicleDetail({
    required this.vehicle,
    required this.onBack,
    required this.onRequest,
  });

  final Vehicle vehicle;
  final VoidCallback onBack;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new)),
            Text(vehicle.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        Text(vehicle.plate, style: const TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onRequest, child: const Text('Request service')),
      ],
    );
  }
}

class _FleetVehiclesOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FleetViewModel>();
    return Material(
      color: AppColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(onPressed: vm.closeVehicles, icon: const Icon(Icons.close)),
                const Text('Fleet vehicles', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
            Expanded(
              child: ListView(
                children: vm.vehicles
                    .map(
                      (v) => ListTile(
                        title: Text(v.label, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(v.plate, style: const TextStyle(color: AppColors.textMuted)),
                        onTap: () => vm.selectVehicle(v),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FleetPaymentOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FleetViewModel>();
    return Material(
      color: AppColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(onPressed: vm.closePayment, icon: const Icon(Icons.close)),
                const Text('Payment methods', style: TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
            const ListTile(
              leading: Icon(Icons.credit_card, color: AppColors.primary),
              title: Text('Visa ·••• 4242', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FleetHelpOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FleetViewModel>();
    return Material(
      color: AppColors.bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(onPressed: vm.closeHelp, icon: const Icon(Icons.close)),
                  const Text('Help & support', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Choose a category', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 12),
              ...HelpCategories.supportTopics.map(
                (e) => ListTile(
                  title: Text(e.$2, style: const TextStyle(color: Colors.white)),
                  onTap: vm.closeHelp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
