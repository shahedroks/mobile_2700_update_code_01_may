import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/fleet_job_summary.dart';
import '../../../data/models/vehicle.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../routes/app_routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/fleet_viewmodel.dart';
import 'notifications_screen.dart';
import 'post_job_screen.dart';

/// Fleet dashboard reference (#000000 bg, accent yellow/green/red/orange).
abstract final class _FleetDashTheme {
  static const Color bgBlack = Color(0xFF000000);
  static const Color statCardBg = Color(0xFF0F0F0F);
  static const Color yellowBannerSubtitle = Color(0xFF78350F);
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
    truck: 'GP 112-033 • Rigid Truck',
    issue: 'Left rear tyre blowout — N14 off-ramp',
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

/// Completed jobs on fleet dashboard (matches `FleetDashboard` in `check.tsx`).
class _FleetCompletedJob {
  const _FleetCompletedJob({
    required this.id,
    required this.truck,
    required this.issue,
    required this.mechanic,
    required this.rating,
    required this.completedDate,
    required this.total,
  });

  final String id;
  final String truck;
  final String issue;
  final String mechanic;
  final int rating;
  final String completedDate;
  final String total;
}

const List<_FleetCompletedJob> _kFleetCompletedDemoJobs = [
  _FleetCompletedJob(
    id: 'TF-8800',
    truck: 'CA 456-789 · Tautliner',
    issue: 'Coolant leak — radiator hose replaced',
    mechanic: 'James M.',
    rating: 5,
    completedDate: '8 Mar 2026',
    total: '£285',
  ),
  _FleetCompletedJob(
    id: 'TF-8791',
    truck: 'GP 112-033 · Rigid Truck',
    issue: 'Battery failure — new battery fitted',
    mechanic: 'Tom S.',
    rating: 5,
    completedDate: '5 Mar 2026',
    total: '£210',
  ),
  _FleetCompletedJob(
    id: 'TF-8783',
    truck: 'KZN 78-99 · Tanker',
    issue: 'Air brake actuator replaced',
    mechanic: 'Paul K.',
    rating: 4,
    completedDate: '2 Mar 2026',
    total: '£425',
  ),
  _FleetCompletedJob(
    id: 'TF-8771',
    truck: 'WC 234-567 · Flatbed',
    issue: 'Dual tyre blowout — 2 tyres replaced',
    mechanic: 'Deon V.',
    rating: 4,
    completedDate: '27 Feb 2026',
    total: '£170',
  ),
  _FleetCompletedJob(
    id: 'TF-8760',
    truck: 'FS 901-445 · Semi',
    issue: 'Starter motor replaced',
    mechanic: 'Sipho M.',
    rating: 5,
    completedDate: '22 Feb 2026',
    total: '£260',
  ),
];

Color _fleetStatusLeftBorder(FleetJobSummary j) {
  final s = j.status.toUpperCase();
  if (s.contains('AWAIT')) return AppColors.primary;
  if (s.contains('ROUT')) return AppColors.orange;
  if (s.contains('POST')) return AppColors.red;
  if (s.contains('ON SITE')) return AppColors.green;
  return AppColors.primary;
}

String _fleetMechanicLabel(FleetJobSummary j) {
  if (j.status.toUpperCase().contains('POST')) return 'Awaiting mechanic…';
  final id = j.id;
  if (id == 'TF-8814' || id == 'TF-8809') return 'Sipho M.';
  return 'James M.';
}

String? _fleetEtaLabel(FleetJobSummary j) {
  if (!j.status.toUpperCase().contains('ROUT')) return null;
  return '18 min';
}

String _fleetTruckDisplay(FleetJobSummary j) => j.truck.replaceAll('•', '·');

String _fleetJobPayDisplay(FleetJobSummary j) {
  return switch (j.id) {
    'TF-8823' => '£275',
    'TF-8821' => '£165',
    'TF-8819' => '£145',
    'TF-8809' => '£260',
    _ => '£—',
  };
}

/// Quotes list for POSTED jobs (`DashboardJobSheet` / `check.tsx`).
class _FleetPostedQuote {
  const _FleetPostedQuote({
    required this.name,
    required this.rating,
    required this.jobs,
    required this.total,
    required this.eta,
    required this.distance,
    required this.responded,
    required this.verified,
    required this.labour,
    required this.callout,
    required this.parts,
    required this.speciality,
  });

  final String name;
  final double rating;
  final int jobs;
  final String total;
  final String eta;
  final String distance;
  final String responded;
  final bool verified;
  final String labour;
  final String callout;
  final String parts;
  final String speciality;
}

const List<_FleetPostedQuote> _kFleetPostedQuotes = [
  _FleetPostedQuote(
    name: 'James Mitchell',
    rating: 4.8,
    jobs: 211,
    total: '£145',
    eta: '12 min',
    distance: '4.2 km',
    responded: '2 min ago',
    verified: true,
    labour: '£85',
    callout: '£35',
    parts: '£25',
    speciality: 'Tyres & Suspension',
  ),
  _FleetPostedQuote(
    name: 'Tom Stevens',
    rating: 4.7,
    jobs: 163,
    total: '£135',
    eta: '22 min',
    distance: '7.8 km',
    responded: '5 min ago',
    verified: true,
    labour: '£80',
    callout: '£35',
    parts: '£20',
    speciality: 'Tyres & Axles',
  ),
  _FleetPostedQuote(
    name: 'Paul Davies',
    rating: 4.5,
    jobs: 98,
    total: '£118',
    eta: '31 min',
    distance: '11 km',
    responded: '9 min ago',
    verified: false,
    labour: '£70',
    callout: '£30',
    parts: '£18',
    speciality: 'General HGV',
  ),
];

class FleetAppShell extends StatelessWidget {
  const FleetAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => FleetViewModel(ctx.read<JobRepository>(), ctx.read<AuthViewModel>()),
      child: const _FleetScaffold(),
    );
  }
}

class _FleetScaffold extends StatelessWidget {
  const _FleetScaffold();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FleetViewModel>();
    final jobs = vm.activeJobs;

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
          onOpenProfile: () => vm.setTab('profile'),
          onOpenChat: vm.openChat,
        );
      case 'post-job':
        return FleetPostJobScreen(
          profileComplete: vm.profileComplete,
          prefilled: vm.prefilledVehicle?.label,
          onSubmit: () => vm.setTab('dashboard'),
          onContinueToJobForm: vm.unlockPostJobFormFromGate,
        );
      case 'tracking':
        return _FleetTrackingList(onOpenDetail: () => vm.setTab('tracking-detail'));
      case 'tracking-detail':
        return _FleetTrackingDetail(onBack: () => vm.setTab('tracking'));
      case 'quote-received':
        return _FleetQuoteReceived(onDone: () => vm.setTab('tracking'));
      case 'profile':
        return _FleetProfile(
          vm: vm,
          onEdit: () => vm.openFleetEditProfile(fromPostJobGate: false),
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
          onCancel: vm.cancelFleetEditProfile,
          openedForPostJob: vm.isEditingProfileForPostJob,
        );
      case 'vehicle-detail':
        final v = vm.selectedVehicle;
        if (v == null) {
          return _FleetDashboard(
            jobs: jobs,
            onPost: () => vm.setTab('post-job'),
            onTracking: () => vm.setTab('tracking'),
            onOpenNotifications: vm.openNotifications,
            onOpenProfile: () => vm.setTab('profile'),
            onOpenChat: vm.openChat,
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
          onOpenProfile: () => vm.setTab('profile'),
          onOpenChat: vm.openChat,
        );
    }
  }
}

class _FleetBottomNav extends StatelessWidget {
  const _FleetBottomNav({required this.vm});

  final FleetViewModel vm;

  static const double _navHit = 36;

  @override
  Widget build(BuildContext context) {
    final active = vm.bottomNavActive;
    const inactiveIcon = Color(0xFF9CA3AF);

    Widget yellowBubble(IconData icon, {double size = 20}) {
      return Container(
        width: _navHit,
        height: _navHit,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: size, color: Colors.black),
      );
    }

    Widget iconFor(String id, bool on) {
      switch (id) {
        case 'dashboard':
          return on
              ? yellowBubble(Icons.grid_view_rounded)
              : SizedBox(
                  width: _navHit,
                  height: _navHit,
                  child: Icon(Icons.grid_view_outlined, size: 22, color: inactiveIcon),
                );
        case 'post-job':
          return on
              ? yellowBubble(Icons.add_rounded, size: 22)
              : SizedBox(
                  width: _navHit,
                  height: _navHit,
                  child: Center(
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: inactiveIcon, width: 1.4),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.add, size: 16, color: inactiveIcon),
                    ),
                  ),
                );
        case 'tracking':
          return on
              ? yellowBubble(Icons.navigation_rounded)
              : SizedBox(
                  width: _navHit,
                  height: _navHit,
                  child: Icon(Icons.near_me_outlined, size: 22, color: inactiveIcon),
                );
        case 'profile':
          return on
              ? yellowBubble(Icons.person_rounded)
              : SizedBox(
                  width: _navHit,
                  height: _navHit,
                  child: Icon(Icons.person_outline_rounded, size: 22, color: inactiveIcon),
                );
        default:
          return SizedBox(width: _navHit, height: _navHit, child: Icon(Icons.circle_outlined, size: 22, color: inactiveIcon));
      }
    }

    Widget item(String id, String label) {
      final on = active == id;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => vm.setTab(id),
            splashColor: AppColors.primary.withValues(alpha: 0.12),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconFor(id, on),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: on ? AppColors.primary : inactiveIcon,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _FleetDashTheme.bgBlack,
        border: Border(top: BorderSide(color: Color(0xFF1A1A1A))),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
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

/// Approve completed work → rate mechanic (`CompletionReviewSheet` / `check.tsx`).
class _FleetCompletionReviewOverlay extends StatefulWidget {
  const _FleetCompletionReviewOverlay({
    required this.mechanic,
    required this.truckLine,
    required this.totalCost,
    required this.onClose,
  });

  final String mechanic;
  final String truckLine;
  final String totalCost;
  final VoidCallback onClose;

  @override
  State<_FleetCompletionReviewOverlay> createState() => _FleetCompletionReviewOverlayState();
}

class _FleetCompletionReviewOverlayState extends State<_FleetCompletionReviewOverlay> {
  bool _showApproval = true;
  bool _showReview = false;
  int _rating = 0;
  final _reviewText = TextEditingController();
  bool _reviewSubmitted = false;

  static const Color _sheetBg = Color(0xFF0E0E0E);
  static const Color _approveGreen = Color(0xFF4ADE80);

  @override
  void dispose() {
    _reviewText.dispose();
    super.dispose();
  }

  void _barrierTap() {
    if (_showReview && _reviewSubmitted) return;
    widget.onClose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) return;
    setState(() => _reviewSubmitted = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _barrierTap,
        behavior: HitTestBehavior.opaque,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.90),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Material(
                color: _sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border2)),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.paddingOf(context).bottom),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      child: _showApproval
                          ? _buildApproval()
                          : _showReview
                              ? _buildReview()
                              : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _grabber() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(99)),
      ),
    );
  }

  Widget _buildApproval() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _grabber(),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _approveGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _approveGreen.withValues(alpha: 0.30)),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.check_circle_rounded, color: _approveGreen, size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'Job Completed',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.2),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.mechanic} has marked this job as complete. Review the work and approve to release payment.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E1E)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'JOB SUMMARY',
                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              _summaryRow('Vehicle', widget.truckLine),
              const SizedBox(height: 10),
              _summaryRow('Mechanic', widget.mechanic),
              const SizedBox(height: 10),
              _summaryRow('Total Cost', widget.totalCost),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Funds will be released to the mechanic within 24 hours of approval',
                  style: TextStyle(color: AppColors.primary, fontSize: 11, height: 1.35, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() {
              _showApproval = false;
              _showReview = true;
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: _approveGreen,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'APPROVE & CONTINUE',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
            ),
          ),
        ),
        TextButton(
          onPressed: widget.onClose,
          child: Text(
            'Review Later',
            style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildReview() {
    if (_reviewSubmitted) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _approveGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _approveGreen.withValues(alpha: 0.30)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check_circle_rounded, color: _approveGreen, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Review Submitted!',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Payment will be released within 24 hours',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _grabber(),
        const Text(
          'Rate Mechanic',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.2),
        ),
        const SizedBox(height: 8),
        Text(
          'How was your experience with ${widget.mechanic}?',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final n = i + 1;
            final on = n <= _rating;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                onPressed: () => setState(() => _rating = n),
                icon: Icon(
                  on ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 40,
                  color: on ? AppColors.primary : const Color(0xFF374151),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'FEEDBACK (OPTIONAL)',
          style: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.95),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reviewText,
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Share your experience with this mechanic...',
            hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.8)),
            filled: true,
            fillColor: AppColors.card2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.40)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _rating > 0 ? _submitReview : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.30),
              disabledForegroundColor: Colors.black.withValues(alpha: 0.40),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'SUBMIT REVIEW',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
            ),
          ),
        ),
        TextButton(
          onPressed: widget.onClose,
          child: Text(
            'Skip for now',
            style: TextStyle(color: const Color(0xFF93C5FD), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Per-job quick view from dashboard (`DashboardJobSheet` / `check.tsx`).
class _FleetDashboardJobOverlay extends StatefulWidget {
  const _FleetDashboardJobOverlay({
    required this.job,
    required this.onClose,
    required this.onOpenChat,
  });

  final FleetJobSummary job;
  final VoidCallback onClose;
  final VoidCallback onOpenChat;

  @override
  State<_FleetDashboardJobOverlay> createState() => _FleetDashboardJobOverlayState();
}

class _FleetDashboardJobOverlayState extends State<_FleetDashboardJobOverlay> {
  int? _expandedQuoteIndex;
  int? _acceptedQuoteIndex;
  bool _cancelOpen = false;

  bool get _isPosted => widget.job.status.toUpperCase().contains('POST');

  bool get _isEnRoute {
    final s = widget.job.status.toUpperCase();
    return s.contains('ROUT');
  }

  bool get _isOnSite {
    final s = widget.job.status.toUpperCase();
    return s.contains('ON SITE');
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onClose,
            behavior: HitTestBehavior.opaque,
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.85)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Material(
                color: const Color(0xFF0E0E0E),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border2)),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 6),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(99)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        widget.job.id,
                                        style: TextStyle(
                                          color: AppColors.textMuted.withValues(alpha: 0.95),
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Color(widget.job.urgencyBgHex),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: Color(widget.job.urgencyColorHex).withValues(alpha: 0.35)),
                                        ),
                                        child: Text(
                                          widget.job.urgency,
                                          style: TextStyle(
                                            color: Color(widget.job.urgencyColorHex),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: Color(widget.job.statusBgHex)),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.job.status,
                                            style: TextStyle(
                                              color: Color(widget.job.statusColorHex),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _fleetTruckDisplay(widget.job),
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.job.issue,
                                    style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 11, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: widget.onClose,
                              style: IconButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A)),
                              icon: Icon(Icons.close_rounded, color: AppColors.textMuted.withValues(alpha: 0.9), size: 20),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: _isPosted ? _buildPostedBody() : _buildActiveBody(),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.paddingOf(context).bottom),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: AppColors.border)),
                        ),
                        child: Column(
                          children: [
                            if (!_isPosted) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        widget.onOpenChat();
                                        widget.onClose();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(color: AppColors.border2),
                                        backgroundColor: const Color(0xFF1A1A1A),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 18),
                                      label: const Text('Chat with Mechanic', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => setState(() => _cancelOpen = true),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.red,
                                        side: BorderSide(color: AppColors.red.withValues(alpha: 0.30)),
                                        backgroundColor: AppColors.red.withValues(alpha: 0.10),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Cancel Job', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: widget.onClose,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textMuted,
                                  side: const BorderSide(color: AppColors.border2),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Close', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_cancelOpen) _buildCancelLayer(),
        ],
      ),
    );
  }

  Widget _buildPostedBody() {
    if (_acceptedQuoteIndex != null) {
      return Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.green.withValues(alpha: 0.30)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Quote Accepted!',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'The mechanic has been notified. We\'ll notify you when they start their journey.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'QUOTES RECEIVED',
              style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            Text(
              '${_kFleetPostedQuotes.length} mechanics responded',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_kFleetPostedQuotes.length, (i) {
          final q = _kFleetPostedQuotes[i];
          final isBest = i == 0;
          final expanded = _expandedQuoteIndex == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isBest ? AppColors.primary.withValues(alpha: 0.30) : const Color(0xFF1E1E1E)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isBest)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        border: Border(bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.20))),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded, color: AppColors.primary, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'FASTEST & HIGHEST RATED',
                            style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: AppAssets.mechanicPortrait,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  width: 44,
                                  height: 44,
                                  color: AppColors.card,
                                  child: const Icon(Icons.person_rounded, color: AppColors.textMuted),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          q.name,
                                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                      if (q.verified) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.green.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppColors.green.withValues(alpha: 0.30)),
                                          ),
                                          child: const Text(
                                            'VERIFIED',
                                            style: TextStyle(color: AppColors.green, fontSize: 8, fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star_rounded, color: AppColors.primary, size: 14),
                                      const SizedBox(width: 4),
                                      Text('${q.rating}', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                                      Text(' · ${q.jobs} jobs · ${q.speciality}', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(q.total, style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w900)),
                                Text(q.responded, style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _FleetDashTheme.statCardBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF1E1E1E)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.navigation_rounded, color: AppColors.orange, size: 14),
                                  const SizedBox(width: 6),
                                  Text('ETA ${q.eta}', style: const TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _FleetDashTheme.statCardBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF1E1E1E)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.place_outlined, color: AppColors.textMuted, size: 14),
                                  const SizedBox(width: 6),
                                  Text('${q.distance} away', style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (expanded) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D0D0D),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1E1E1E)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'QUOTE BREAKDOWN',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                                ),
                                const SizedBox(height: 8),
                                _quoteBreakRow('Labour', q.labour),
                                _quoteBreakRow('Call-out Fee', q.callout),
                                _quoteBreakRow('Parts (est.)', q.parts),
                                const Divider(color: AppColors.border2, height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                                    Text(q.total, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => setState(() => _acceptedQuoteIndex = i),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                label: Text('Accept · ${q.total}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => setState(() => _expandedQuoteIndex = expanded ? null : i),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF1A1A1A),
                                side: const BorderSide(color: AppColors.border2),
                                padding: const EdgeInsets.all(12),
                              ),
                              icon: Icon(expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _quoteBreakRow(String a, String b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(a, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          Text(b, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActiveBody() {
    final eta = _fleetEtaLabel(widget.job);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 8,
                  left: 12,
                  child: Text(
                    'TruckFix Maps',
                    style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.85), fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.60),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
                    ),
                    child: Text(
                      _isEnRoute ? 'LIVE' : 'MAP',
                      style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E1E)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'STATUS',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              _statusStep('Job Posted', done: true, highlight: false),
              _statusStep('Mechanic Assigned', done: true, highlight: false),
              _statusStep('En Route', done: _isEnRoute || _isOnSite, highlight: _isEnRoute && !_isOnSite, eta: _isEnRoute && !_isOnSite ? eta : null),
              _statusStep('On Site', done: _isOnSite, highlight: _isOnSite),
              _statusStep('Completed', done: false, highlight: false),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E1E)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: AppAssets.mechanicPortrait,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    color: AppColors.card,
                    child: const Icon(Icons.person_rounded, color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _fleetMechanicLabel(widget.job),
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.green.withValues(alpha: 0.30)),
                          ),
                          child: const Text(
                            'VERIFIED',
                            style: TextStyle(color: AppColors.green, fontSize: 8, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text('4.9', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                        Text(' · 184 jobs', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.phone_rounded, color: AppColors.primary, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusStep(
    String label, {
    required bool done,
    required bool highlight,
    String? eta,
  }) {
    final bg = !done
        ? const Color(0xFF1A1A1A)
        : highlight
            ? AppColors.primary
            : AppColors.green;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bg,
              border: !done ? Border.all(color: AppColors.border2) : null,
            ),
            alignment: Alignment.center,
            child: done
                ? Icon(Icons.check_rounded, size: 14, color: highlight ? Colors.black : Colors.black)
                : Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF333333), shape: BoxShape.circle),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: done ? Colors.white : AppColors.textHint,
              ),
            ),
          ),
          if (eta != null)
            Text('ETA $eta', style: const TextStyle(color: AppColors.orange, fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildCancelLayer() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _cancelOpen = false),
        behavior: HitTestBehavior.opaque,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.85),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Cancel this job?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(
                      _isEnRoute || _isOnSite
                          ? 'The mechanic may be on the way. A cancellation fee may apply for emergency jobs.'
                          : 'You can cancel this booking from the dashboard.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.35),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _cancelOpen = false);
                        widget.onClose();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job cancelled (demo)')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Confirm cancellation', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => setState(() => _cancelOpen = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        side: const BorderSide(color: AppColors.border2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Keep job active'),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
    required this.onOpenProfile,
    required this.onOpenChat,
  });

  final List<FleetJobSummary> jobs;
  final VoidCallback onPost;
  final VoidCallback onTracking;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenChat;

  @override
  State<_FleetDashboard> createState() => _FleetDashboardState();
}

class _FleetDashboardState extends State<_FleetDashboard> {
  bool _showActiveJobs = true;
  FleetJobSummary? _jobSheetJob;
  FleetJobSummary? _completionJob;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FleetViewModel>();
    const companyName = 'Logistix Transport';
    final displayJobs = widget.jobs.isNotEmpty ? widget.jobs : _kDashboardDemoJobs;
    final activeJobCount = widget.jobs.length;
    final completedJobCount = vm.hasLoadedOnce ? vm.completedJobs.length : _kFleetCompletedDemoJobs.length;
    FleetJobSummary? awaitingJob;
    for (final j in displayJobs) {
      if (j.status.toUpperCase().contains('AWAITING')) {
        awaitingJob = j;
        break;
      }
    }
    final hasAwaitingApproval = awaitingJob != null;

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
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF1E1E1E)),
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
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: widget.onOpenProfile,
                      borderRadius: BorderRadius.circular(16),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Text(
                            'LT',
                            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
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
      required Color dot,
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
            border: Border.all(color: const Color(0xFF1A1A1A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Icon(icon, size: 14, color: accent),
                ],
              ),
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
      final vm = context.watch<FleetViewModel>();
      final month = (vm.spendMonth.trim().isEmpty) ? 'This Month' : '${vm.spendMonth} Spend';
      final sym = switch (vm.spendCurrency.toUpperCase()) {
        'GBP' => '£',
        'USD' => r'$',
        'EUR' => '€',
        _ => '',
      };
      final total = '$sym${vm.spendTotal.round()}';
      final budget = vm.spendBudget;
      final util = vm.spendUtilizationPct ??
          ((budget != null && budget > 0) ? (vm.spendTotal / budget) * 100.0 : null);
      final progress = ((util ?? 0) / 100.0).clamp(0.0, 1.0);

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1A1A1A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  month,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Text(
                  total,
                  style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFF2A2A2A),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              (budget == null || budget <= 0)
                  ? 'No budget set'
                  : '${(util ?? 0).round()}% of monthly budget ($sym${budget.round()})',
              style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.9), fontSize: 11, height: 1.3),
            ),
          ],
        ),
      );
    }

    Widget activeJobCard(FleetJobSummary j) {
      final leftBorder = _fleetStatusLeftBorder(j);
      final statusColor = Color(j.statusColorHex);
      final statusDot = Color(j.statusBgHex);
      final urgencyFg = Color(j.urgencyColorHex);
      final mechanicLabel = _fleetMechanicLabel(j);
      final eta = _fleetEtaLabel(j);

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              final s = j.status.toUpperCase();
              if (s.contains('AWAITING')) {
                setState(() {
                  _completionJob = j;
                  _jobSheetJob = null;
                });
              } else {
                setState(() {
                  _jobSheetJob = j;
                  _completionJob = null;
                });
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: _FleetDashTheme.statCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E1E1E)),
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: leftBorder),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        j.id,
                                        style: TextStyle(
                                          color: AppColors.textMuted.withValues(alpha: 0.95),
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Color(j.urgencyBgHex),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: urgencyFg.withValues(alpha: 0.35)),
                                        ),
                                        child: Text(
                                          j.urgency,
                                          style: TextStyle(
                                            color: urgencyFg,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 130),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: statusDot),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            j.status,
                                            textAlign: TextAlign.right,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              j.truck.replaceAll('•', '·'),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              j.issue,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.build_outlined, size: 11, color: AppColors.textMuted.withValues(alpha: 0.9)),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    mechanicLabel,
                                    style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (eta != null) ...[
                                  Text(
                                    'ETA $eta',
                                    style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textHint.withValues(alpha: 0.9)),
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

    Widget completedJobCard(_FleetCompletedJob job) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E1E)),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: AppColors.green),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    job.id,
                                    style: TextStyle(
                                      color: AppColors.textMuted.withValues(alpha: 0.95),
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.green.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: AppColors.green.withValues(alpha: 0.30)),
                                    ),
                                    child: const Text(
                                      'DONE',
                                      style: TextStyle(
                                        color: AppColors.green,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              job.completedDate,
                              style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.9), fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.truck,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.issue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(color: Color(0xFF1A1A1A), shape: BoxShape.circle),
                              child: Icon(Icons.build_outlined, size: 11, color: AppColors.textMuted.withValues(alpha: 0.9)),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              job.mechanic,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                            ),
                            const SizedBox(width: 6),
                            ...List.generate(5, (i) {
                              final on = i < job.rating;
                              return Padding(
                                padding: const EdgeInsets.only(right: 1),
                                child: Icon(
                                  Icons.star_rounded,
                                  size: 12,
                                  color: on ? AppColors.primary : const Color(0xFF374151),
                                ),
                              );
                            }),
                            const Spacer(),
                            Text(
                              job.total,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: AppColors.border)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _FleetInvoiceAction(
                                  icon: Icons.description_outlined,
                                  label: 'View Invoice',
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Invoice ${job.id}')),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              _FleetInvoiceAction(
                                icon: Icons.download_outlined,
                                label: 'PDF',
                                compact: true,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Download PDF')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _FleetDashTheme.bgBlack,
      appBar: dashboardAppBar(),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: const Color(0xFF111111),
            onRefresh: vm.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
          Row(
            children: [
              statChip(
                icon: Icons.bolt_rounded,
                dot: AppColors.primary,
                accent: AppColors.primary,
                value: vm.activeCount > 0 ? '${vm.activeCount}' : '0',
                caption: 'ACTIVE',
              ),
              const SizedBox(width: 10),
              statChip(
                icon: Icons.warning_amber_rounded,
                dot: AppColors.red,
                accent: AppColors.red,
                value: vm.awaitingCount > 0 ? '${vm.awaitingCount}' : '0',
                caption: 'AWAITING',
              ),
              const SizedBox(width: 10),
              statChip(
                icon: Icons.check_circle_outline_rounded,
                dot: AppColors.green,
                accent: AppColors.green,
                value: vm.monthCompletedCount > 0 ? '${vm.monthCompletedCount}' : '0',
                caption: 'THIS MONTH',
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (vm.loading)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Updating dashboard…',
                    style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 12),
                  ),
                ],
              ),
            ),
          if (!vm.loading && vm.loadError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vm.loadError!,
                      style: TextStyle(color: AppColors.red.withValues(alpha: 0.95), fontSize: 12, height: 1.3),
                    ),
                  ),
                  TextButton(
                    onPressed: vm.refresh,
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          if (hasAwaitingApproval) ...[
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  if (awaitingJob != null) {
                    setState(() {
                      _completionJob = awaitingJob;
                      _jobSheetJob = null;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.green.withValues(alpha: 0.30), width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Job Awaiting Approval',
                              style: TextStyle(color: AppColors.green, fontSize: 14, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tap to review & release payment',
                              style: TextStyle(color: Color(0xFF86EFAC), fontSize: 11, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: AppColors.green.withValues(alpha: 0.85), size: 22),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
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
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.add_circle_outline_rounded, color: Colors.black, size: 24),
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
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E1E1E)),
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
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            decoration: BoxDecoration(
                              color: _showActiveJobs ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _showActiveJobs ? Colors.black.withValues(alpha: 0.20) : const Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    '$activeJobCount',
                                    style: TextStyle(
                                      fontSize: 9,
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
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            decoration: BoxDecoration(
                              color: !_showActiveJobs ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: !_showActiveJobs ? Colors.black.withValues(alpha: 0.20) : const Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    '$completedJobCount',
                                    style: TextStyle(
                                      fontSize: 9,
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
              if (_showActiveJobs)
                TextButton(
                  onPressed: widget.onTracking,
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: const EdgeInsets.only(left: 10)),
                  child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_showActiveJobs) ...displayJobs.map(activeJobCard),
          if (!_showActiveJobs)
            ...((vm.hasLoadedOnce)
                ? (vm.completedJobs.isEmpty
                    ? [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF1E1E1E)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded, color: AppColors.textMuted, size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'No completed jobs yet.',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    : vm.completedJobs.map((j) {
                        final d = _FleetCompletedJob(
                          id: j.id,
                          truck: j.truck,
                          issue: j.issue,
                          mechanic: j.mechanic,
                          rating: j.rating,
                          completedDate: j.completedDate,
                          total: j.total,
                        );
                        return completedJobCard(d);
                      }))
                : _kFleetCompletedDemoJobs.map(completedJobCard)),
          const SizedBox(height: 8),
          marchSpendCard(),
              ],
            ),
          ),
          if (_completionJob != null)
            _FleetCompletionReviewOverlay(
              mechanic: _fleetMechanicLabel(_completionJob!),
              truckLine: _fleetTruckDisplay(_completionJob!),
              totalCost: _fleetJobPayDisplay(_completionJob!),
              onClose: () => setState(() => _completionJob = null),
            ),
          if (_jobSheetJob != null)
            _FleetDashboardJobOverlay(
              job: _jobSheetJob!,
              onClose: () => setState(() => _jobSheetJob = null),
              onOpenChat: widget.onOpenChat,
            ),
        ],
      ),
    );
  }
}

class _FleetInvoiceAction extends StatelessWidget {
  const _FleetInvoiceAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: compact ? 12 : 8),
          decoration: BoxDecoration(
            color: AppColors.card2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Icon(icon, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

enum _FleetTrackStatus { posted, assigned, enRoute, onSite }

class _FleetTrackingJob {
  const _FleetTrackingJob({
    required this.id,
    required this.truck,
    required this.issue,
    required this.status,
    required this.mechanic,
    required this.eta,
    required this.pay,
    required this.ago,
    required this.emergency,
    this.quoteAgreed = false,
    this.scheduledFor,
  });

  final String id;
  final String truck;
  final String issue;
  final _FleetTrackStatus status;
  final String? mechanic;
  final String? eta;
  final String pay;
  final String ago;
  final bool emergency;
  final bool quoteAgreed;
  final DateTime? scheduledFor;
}

({Color bar, Color fg, Color badgeBg, Color badgeBorder, String shortLabel, bool pulse}) _fleetTrackCfg(_FleetTrackStatus s) {
  return switch (s) {
    _FleetTrackStatus.posted => (
        bar: AppColors.red,
        fg: AppColors.red,
        badgeBg: AppColors.red.withValues(alpha: 0.10),
        badgeBorder: AppColors.red.withValues(alpha: 0.30),
        shortLabel: 'POSTED',
        pulse: true,
      ),
    _FleetTrackStatus.assigned => (
        bar: const Color(0xFF60A5FA),
        fg: const Color(0xFF60A5FA),
        badgeBg: const Color(0xFF60A5FA).withValues(alpha: 0.10),
        badgeBorder: const Color(0xFF60A5FA).withValues(alpha: 0.30),
        shortLabel: 'ASSIGNED',
        pulse: false,
      ),
    _FleetTrackStatus.enRoute => (
        bar: AppColors.orange,
        fg: AppColors.orange,
        badgeBg: AppColors.orange.withValues(alpha: 0.10),
        badgeBorder: AppColors.orange.withValues(alpha: 0.30),
        shortLabel: 'EN ROUTE',
        pulse: true,
      ),
    _FleetTrackStatus.onSite => (
        bar: AppColors.green,
        fg: AppColors.green,
        badgeBg: AppColors.green.withValues(alpha: 0.10),
        badgeBorder: AppColors.green.withValues(alpha: 0.30),
        shortLabel: 'ON SITE',
        pulse: true,
      ),
  };
}

bool _fleetTrackingHasFee(_FleetTrackingJob job) {
  if (job.status == _FleetTrackStatus.enRoute || job.status == _FleetTrackStatus.onSite) return true;
  if (job.emergency) return false;
  if (job.scheduledFor != null) {
    final hours = job.scheduledFor!.difference(DateTime.now()).inMinutes / 60.0;
    return hours < 24;
  }
  return false;
}

String _fleetCancelFeeAmount(_FleetTrackingJob job) {
  final n = double.tryParse(job.pay.replaceAll('£', '').trim()) ?? 0;
  return '£${(n * 0.1).round()}';
}

class _FleetTrackingList extends StatefulWidget {
  const _FleetTrackingList({required this.onOpenDetail});

  final VoidCallback onOpenDetail;

  @override
  State<_FleetTrackingList> createState() => _FleetTrackingListState();
}

class _FleetTrackingListState extends State<_FleetTrackingList> with SingleTickerProviderStateMixin {
  late final List<_FleetTrackingJob> _jobs;
  _FleetTrackingJob? _cancelJob;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    final now = DateTime.now();
    _jobs = [
      const _FleetTrackingJob(
        id: 'TF-8821',
        truck: 'Tautliner · CA 456-789',
        issue: 'Engine overheating — M1 near Birmingham',
        status: _FleetTrackStatus.posted,
        mechanic: null,
        eta: null,
        pay: '£165',
        ago: '4 min ago',
        emergency: true,
        quoteAgreed: false,
      ),
      _FleetTrackingJob(
        id: 'TF-8819',
        truck: 'Rigid Truck · GP 112-033',
        issue: 'Left rear tyre blowout — M6 services',
        status: _FleetTrackStatus.assigned,
        mechanic: 'Tom S.',
        eta: null,
        pay: '£95',
        ago: '18 min ago',
        emergency: false,
        scheduledFor: now.add(const Duration(hours: 30)),
      ),
      _FleetTrackingJob(
        id: 'TF-8822',
        truck: 'Tanker · KZN 78-99',
        issue: 'Air brake fault — A1 Leeds',
        status: _FleetTrackStatus.enRoute,
        mechanic: 'James M.',
        eta: '12 min',
        pay: '£310',
        ago: '35 min ago',
        emergency: false,
        scheduledFor: now.add(const Duration(hours: 6)),
      ),
      const _FleetTrackingJob(
        id: 'TF-8814',
        truck: 'Semi · WC 234-567',
        issue: 'Fuel leak suspected — M25 London',
        status: _FleetTrackStatus.onSite,
        mechanic: 'Paul K.',
        eta: null,
        pay: '£185',
        ago: '1 hr ago',
        emergency: true,
        quoteAgreed: true,
      ),
    ];
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  bool _canCancel(_FleetTrackStatus s) => s != _FleetTrackStatus.onSite;

  String _cancelButtonLabel(_FleetTrackingJob job) {
    if (job.status == _FleetTrackStatus.enRoute) return 'Cancel';
    if (_fleetTrackingHasFee(job)) return 'Cancel · ${_fleetCancelFeeAmount(job)}';
    return 'Cancel - Free';
  }

  Widget _cancelModal() {
    final job = _cancelJob;
    if (job == null) return const SizedBox.shrink();
    final fee = _fleetTrackingHasFee(job);
    final feeStr = _fleetCancelFeeAmount(job);

    String bodyText() {
      if (fee) {
        if (job.emergency) {
          return 'The mechanic is on the way. A 10% cancellation fee ($feeStr) applies for emergency jobs once the mechanic is en route.';
        }
        return 'Your booking is less than 24 hours away. A 10% late-cancellation fee ($feeStr) applies.';
      }
      if (job.status == _FleetTrackStatus.posted) {
        return 'No mechanic assigned yet — free cancellation.';
      }
      return 'Mechanic has not started journey — free cancellation.';
    }

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.85),
        child: InkWell(
          onTap: () => setState(() => _cancelJob = null),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cancel ${job.id}?', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(job.truck, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text(
                                bodyText(),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (fee) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.red.withValues(alpha: 0.20)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppColors.red.withValues(alpha: 0.9), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '10% cancellation fee · $feeStr · Non-refundable',
                                style: TextStyle(color: AppColors.red.withValues(alpha: 0.95), fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() => _cancelJob = null),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        fee ? 'Confirm Cancellation ($feeStr fee)' : 'Confirm Cancellation — Free',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => setState(() => _cancelJob = null),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Keep Job Active', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: const BoxDecoration(
                color: _FleetDashTheme.bgBlack,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Job Tracking', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text(
                    '${_jobs.length} active jobs',
                    style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 11),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: _jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final job = _jobs[index];
                  final cfg = _fleetTrackCfg(job.status);
                  final fee = _fleetTrackingHasFee(job);
                  final canCancel = _canCancel(job.status);

                  Widget statusDot() {
                    if (!cfg.pulse) {
                      return Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: cfg.bar, shape: BoxShape.circle),
                      );
                    }
                    return AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        return Opacity(opacity: 0.45 + 0.55 * _pulse.value, child: child);
                      },
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: cfg.bar, shape: BoxShape.circle),
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(width: 4, color: cfg.bar),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  job.id,
                                                  style: TextStyle(
                                                    color: AppColors.textMuted.withValues(alpha: 0.95),
                                                    fontSize: 10,
                                                    fontFamily: 'monospace',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(' · ', style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.8), fontSize: 10)),
                                                Text(
                                                  job.ago,
                                                  style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 10),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              job.truck.replaceAll('·', ' - '),
                                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: cfg.badgeBg,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: cfg.badgeBorder),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            statusDot(),
                                            const SizedBox(width: 6),
                                            Text(
                                              cfg.shortLabel,
                                              style: TextStyle(
                                                color: cfg.fg,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    job.issue,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      if (job.mechanic != null)
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(color: Color(0xFF1A1A1A), shape: BoxShape.circle),
                                                child: Icon(Icons.build_outlined, size: 11, color: AppColors.textMuted.withValues(alpha: 0.9)),
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  job.mechanic!,
                                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w600),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(color: Color(0xFF1A1A1A), shape: BoxShape.circle),
                                                child: Icon(Icons.schedule_rounded, size: 11, color: AppColors.textHint),
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'Awaiting mechanic…',
                                                  style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 11),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (job.eta != null) ...[
                                            Icon(Icons.near_me_rounded, size: 14, color: AppColors.orange),
                                            const SizedBox(width: 4),
                                            Text(
                                              job.eta!,
                                              style: const TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.w900),
                                            ),
                                            const SizedBox(width: 12),
                                          ],
                                          Text(
                                            job.pay,
                                            style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w900),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.only(top: 10),
                                    decoration: const BoxDecoration(
                                      border: Border(top: BorderSide(color: AppColors.border)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: widget.onOpenDetail,
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.textSecondary,
                                              backgroundColor: AppColors.card2,
                                              side: const BorderSide(color: AppColors.border2),
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.location_on_rounded, size: 15, color: AppColors.primary),
                                                SizedBox(width: 6),
                                                Text('Track Job', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: canCancel
                                              ? OutlinedButton(
                                                  onPressed: () => setState(() => _cancelJob = job),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: fee ? AppColors.red : AppColors.textMuted,
                                                    side: BorderSide(
                                                      color: fee ? AppColors.red.withValues(alpha: 0.40) : AppColors.border2,
                                                    ),
                                                    backgroundColor: fee ? AppColors.red.withValues(alpha: 0.05) : AppColors.card2,
                                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.close_rounded, size: 15, color: fee ? AppColors.red : AppColors.textMuted),
                                                      const SizedBox(width: 4),
                                                      Flexible(
                                                        child: Text(
                                                          _cancelButtonLabel(job),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w600,
                                                            color: fee ? AppColors.red : AppColors.textMuted,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : OutlinedButton(
                                                  onPressed: null,
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: AppColors.textHint,
                                                    side: const BorderSide(color: AppColors.border),
                                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.check_circle_outline_rounded, size: 15, color: AppColors.textHint),
                                                      SizedBox(width: 6),
                                                      Text('Mechanic on site', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
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
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        _cancelModal(),
      ],
    );
  }
}

class _FleetDetailTimelineStep {
  const _FleetDetailTimelineStep({required this.flowKey, required this.label, required this.time});

  final String flowKey;
  final String label;
  final String time;
}

const List<_FleetDetailTimelineStep> _kFleetDetailTimeline = [
  _FleetDetailTimelineStep(flowKey: 'posted', label: 'Posted', time: '14:32'),
  _FleetDetailTimelineStep(flowKey: 'assigned', label: 'Assigned', time: '14:38'),
  _FleetDetailTimelineStep(flowKey: 'en_route', label: 'En Route', time: '14:41'),
  _FleetDetailTimelineStep(flowKey: 'arrived', label: 'Arrived', time: 'ETA 14:58'),
  _FleetDetailTimelineStep(flowKey: 'in_progress', label: 'In Progress', time: '—'),
  _FleetDetailTimelineStep(flowKey: 'completed', label: 'Completed', time: '—'),
];

const List<String> _kFleetDetailFlowOrder = ['posted', 'assigned', 'en_route', 'arrived', 'in_progress', 'completed'];

({Color dot, Color fg, Color bg, Color border, String shortLabel}) _fleetDetailHeaderBadge(int stepIdx) {
  return switch (stepIdx) {
    0 => (
        dot: AppColors.red,
        fg: AppColors.red,
        bg: AppColors.red.withValues(alpha: 0.10),
        border: AppColors.red.withValues(alpha: 0.30),
        shortLabel: 'POSTED',
      ),
    1 => (
        dot: const Color(0xFF60A5FA),
        fg: const Color(0xFF60A5FA),
        bg: const Color(0xFF60A5FA).withValues(alpha: 0.10),
        border: const Color(0xFF60A5FA).withValues(alpha: 0.30),
        shortLabel: 'ASSIGNED',
      ),
    2 => (
        dot: AppColors.orange,
        fg: AppColors.orange,
        bg: AppColors.orange.withValues(alpha: 0.10),
        border: AppColors.orange.withValues(alpha: 0.30),
        shortLabel: 'EN ROUTE',
      ),
    3 => (
        dot: AppColors.primary,
        fg: AppColors.primary,
        bg: AppColors.primary.withValues(alpha: 0.10),
        border: AppColors.primary.withValues(alpha: 0.30),
        shortLabel: 'ARRIVED',
      ),
    4 => (
        dot: AppColors.orange,
        fg: AppColors.orange,
        bg: AppColors.orange.withValues(alpha: 0.10),
        border: AppColors.orange.withValues(alpha: 0.30),
        shortLabel: 'IN PROGRESS',
      ),
    _ => (
        dot: AppColors.green,
        fg: AppColors.green,
        bg: AppColors.green.withValues(alpha: 0.10),
        border: AppColors.green.withValues(alpha: 0.30),
        shortLabel: 'COMPLETED',
      ),
  };
}

class _FleetTrackingDetail extends StatefulWidget {
  const _FleetTrackingDetail({required this.onBack});

  final VoidCallback onBack;

  @override
  State<_FleetTrackingDetail> createState() => _FleetTrackingDetailState();
}

class _FleetTrackingDetailState extends State<_FleetTrackingDetail> with SingleTickerProviderStateMixin {
  int _jobStep = 2;
  String _paymentStatus = 'authorised';
  bool _cancelOpen = false;
  bool _contactOpen = false;
  bool _ratingOpen = false;
  int _ratingValue = 0;
  final _ratingComment = TextEditingController();
  bool _ratingSubmitted = false;
  late final AnimationController _headerPulse;

  static const _detailFee = '£31';

  @override
  void initState() {
    super.initState();
    _headerPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerPulse.dispose();
    _ratingComment.dispose();
    super.dispose();
  }

  bool get _mechanicAssigned => _jobStep >= 1;
  bool get _mechanicStartedJourney => _jobStep >= 2;
  bool get _detailHasFee => _jobStep >= 2 && _jobStep <= 4;

  int _flowIndex(String key) => _kFleetDetailFlowOrder.indexOf(key);

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.6,
      ),
    );
  }

  Widget _cancelSheet() {
    return _FleetDetailBottomOverlay(
      onBarrierTap: () => setState(() => _cancelOpen = false),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cancel this job?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(
                        _detailHasFee
                            ? 'The mechanic is on the way. A 10% cancellation fee ($_detailFee) applies for emergency jobs once the mechanic is en route.'
                            : _jobStep == 0
                                ? 'No mechanic assigned yet — free cancellation.'
                                : 'Mechanic has not started journey — free cancellation.',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_detailHasFee) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.red.withValues(alpha: 0.9), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '10% cancellation fee · $_detailFee · Non-refundable',
                        style: TextStyle(color: AppColors.red.withValues(alpha: 0.95), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _cancelOpen = false),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _detailHasFee ? 'Confirm Cancellation ($_detailFee fee)' : 'Confirm Cancellation — Free',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => setState(() => _cancelOpen = false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Keep Job Active', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactSheet() {
    return _FleetDetailBottomOverlay(
      onBarrierTap: () => setState(() => _contactOpen = false),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(imageUrl: AppAssets.mechanicPortrait, width: 40, height: 40, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('James Mitchell', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                      SizedBox(height: 2),
                      Text('+44 7734 567 890', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _contactOpen = false),
                  icon: Icon(Icons.close_rounded, color: AppColors.textMuted.withValues(alpha: 0.8)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Call not wired in prototype')));
                setState(() => _contactOpen = false);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Call Mechanic', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => setState(() => _contactOpen = false),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Text('Send Message', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratingSheet() {
    return _FleetDetailBottomOverlay(
      onBarrierTap: _ratingSubmitted ? null : () => setState(() => _ratingOpen = false),
      align: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF0E0E0E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          border: Border(top: BorderSide(color: AppColors.border2)),
        ),
        child: SafeArea(
          top: false,
          child: _ratingSubmitted
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.border2, borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.green, width: 2),
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 34),
                    ),
                    const SizedBox(height: 14),
                    const Text('Review Submitted!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    const Text(
                      'Thanks for rating James. Your feedback helps keep the network reliable.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border2, borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(imageUrl: AppAssets.mechanicPortrait, width: 48, height: 48, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('James Mitchell', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                              SizedBox(height: 2),
                              Text('Job TF-8821 · Engine overheating', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('YOUR RATING', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final n = i + 1;
                        final on = n <= _ratingValue;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: InkWell(
                            onTap: () => setState(() => _ratingValue = n),
                            child: Icon(Icons.star_rounded, size: 36, color: on ? AppColors.primary : const Color(0xFF2A2A2A)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _ratingValue == 0
                          ? ''
                          : switch (_ratingValue) {
                              1 => 'Poor',
                              2 => 'Fair',
                              3 => 'Good',
                              4 => 'Very Good',
                              _ => 'Excellent!',
                            },
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'COMMENT (OPTIONAL)',
                      style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ratingComment,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Punctuality, quality of repair, professionalism...',
                        hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.7)),
                        filled: true,
                        fillColor: AppColors.card2,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _ratingValue == 0
                          ? null
                          : () async {
                              setState(() => _ratingSubmitted = true);
                              await Future<void>.delayed(const Duration(milliseconds: 1800));
                              if (mounted) setState(() => _ratingOpen = false);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.card2,
                        foregroundColor: Colors.black,
                        disabledForegroundColor: AppColors.textHint,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('SUBMIT REVIEW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _ratingOpen = false),
                      child: const Text('Not now', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = _fleetDetailHeaderBadge(_jobStep);
    final paymentCfg = switch (_paymentStatus) {
      'authorised' => (label: 'Authorised', fg: AppColors.orange, bg: AppColors.orange.withValues(alpha: 0.10), bd: AppColors.orange.withValues(alpha: 0.30)),
      'paid' => (label: 'Paid', fg: AppColors.green, bg: AppColors.green.withValues(alpha: 0.10), bd: AppColors.green.withValues(alpha: 0.30)),
      'refunded' => (label: 'Refunded', fg: const Color(0xFF60A5FA), bg: const Color(0xFF60A5FA).withValues(alpha: 0.10), bd: const Color(0xFF60A5FA).withValues(alpha: 0.30)),
      _ => (label: 'Released to Mechanic', fg: AppColors.primary, bg: AppColors.primary.withValues(alpha: 0.10), bd: AppColors.primary.withValues(alpha: 0.30)),
    };

    return Stack(
      children: [
        ColoredBox(
          color: AppColors.bg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: AppColors.card2,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: widget.onBack,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border2),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'TF-8821',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: badge.bg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: badge.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _jobStep == 2
                                        ? AnimatedBuilder(
                                            animation: _headerPulse,
                                            builder: (context, c) => Opacity(opacity: 0.5 + 0.5 * _headerPulse.value, child: c),
                                            child: Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(color: badge.dot, shape: BoxShape.circle),
                                            ),
                                          )
                                        : Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(color: badge.dot, shape: BoxShape.circle),
                                          ),
                                    const SizedBox(width: 6),
                                    Text(
                                      badge.shortLabel,
                                      style: TextStyle(color: badge.fg, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'CA 456-789 · Tautliner · Engine overheating',
                            style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 11, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E1E1E)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('STATUS TIMELINE'),
                          const SizedBox(height: 16),
                          ...List.generate(_kFleetDetailTimeline.length, (i) {
                            final step = _kFleetDetailTimeline[i];
                            final stepIdx = _flowIndex(step.flowKey);
                            final isDone = stepIdx <= _jobStep;
                            final isActive = stepIdx == _jobStep;
                            final isLast = i == _kFleetDetailTimeline.length - 1;
                            final lineColor = !isDone
                                ? const Color(0xFF1E1E1E)
                                : (isDone && !isActive)
                                    ? AppColors.primary.withValues(alpha: 0.50)
                                    : AppColors.primary.withValues(alpha: 0.30);

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDone ? AppColors.primary : AppColors.card,
                                        border: Border.all(
                                          color: isDone ? AppColors.primary : AppColors.border2,
                                          width: 2,
                                        ),
                                        boxShadow: isActive
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primary.withValues(alpha: 0.45),
                                                  blurRadius: 12,
                                                  spreadRadius: 0,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: isDone
                                          ? const Icon(Icons.check_rounded, size: 16, color: Colors.black)
                                          : Center(
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(color: Color(0xFF2A2A2A), shape: BoxShape.circle),
                                              ),
                                            ),
                                    ),
                                    if (!isLast)
                                      Container(
                                        width: 2,
                                        height: 22,
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        color: lineColor,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            step.label,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: isActive
                                                  ? AppColors.primary
                                                  : isDone
                                                      ? Colors.white
                                                      : const Color(0xFF374151),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          isDone || isActive ? step.time : '—',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontFamily: 'monospace',
                                            color: isActive
                                                ? AppColors.primary.withValues(alpha: 0.70)
                                                : isDone
                                                    ? AppColors.textMuted
                                                    : const Color(0xFF1F2937),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ],
                            );
                          }),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.only(top: 12),
                            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                            child: Row(
                              children: [
                                Text('DEMO:', style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.85), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: List.generate(_kFleetDetailFlowOrder.length, (i) {
                                      final key = _kFleetDetailFlowOrder[i];
                                      final label = key.replaceAll('_', ' ');
                                      final on = _jobStep == i;
                                      return InkWell(
                                        onTap: () => setState(() => _jobStep = i),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: on ? AppColors.primary : AppColors.card2,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: on ? AppColors.primary : AppColors.border2),
                                          ),
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w900,
                                              color: on ? Colors.black : AppColors.textMuted,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_mechanicAssigned)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E1E1E)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('ASSIGNED MECHANIC'),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: AppAssets.mechanicPortrait,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('James Mitchell', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
                                          SizedBox(width: 4),
                                          Text('4.9', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                                          Text(' · 184 jobs', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text('+44 7734 567 890', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Call not wired in prototype'))),
                                    borderRadius: BorderRadius.circular(12),
                                    child: const SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: Icon(Icons.call_rounded, color: Colors.black, size: 22),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.only(top: 12),
                              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                              child: Row(
                                children: [
                                  Icon(Icons.schedule_rounded, size: 16, color: AppColors.textHint),
                                  const SizedBox(width: 8),
                                  Text('ETA (from mechanic)', style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 12)),
                                  const Spacer(),
                                  const Text('18 min', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E1E1E)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.build_outlined, color: AppColors.textHint.withValues(alpha: 0.5)),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Awaiting mechanic assignment', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                                  SizedBox(height: 4),
                                  Text('A nearby mechanic will be assigned shortly', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E1E1E)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('BREAKDOWN LOCATION'),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on_outlined, size: 18, color: AppColors.textMuted.withValues(alpha: 0.9)),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'N1 Northbound, near Buccleuch Interchange, Sandton, Gauteng',
                                  style: TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton(
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open in Maps'))),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.30)),
                              backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.open_in_new_rounded, size: 16),
                                SizedBox(width: 8),
                                Text('Open in Google Maps', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E1E1E)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _sectionTitle('PAYMENT'),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: paymentCfg.bg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: paymentCfg.bd),
                                ),
                                child: Text(
                                  paymentCfg.label,
                                  style: TextStyle(color: paymentCfg.fg, fontSize: 10, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _payRow('Quote Amount', '£165', brightValue: true),
                          _payRow('Platform Fee (12%)', '£20', mutedValue: true),
                          _payRow('Pre-Auth Held', '£220', valueColor: AppColors.orange),
                          _payRow('Card', 'VISA •••• 4891', mutedValue: true),
                          const Divider(color: AppColors.border2, height: 20),
                          _payRow('Total Payable', '£185', brightValue: true, valueYellow: true),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.only(top: 12),
                            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: ['authorised', 'paid', 'refunded', 'released'].map((s) {
                                final on = _paymentStatus == s;
                                return InkWell(
                                  onTap: () => setState(() => _paymentStatus = s),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: on ? AppColors.primary : AppColors.card2,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: on ? AppColors.primary : AppColors.border2),
                                    ),
                                    child: Text(
                                      s,
                                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: on ? Colors.black : AppColors.textMuted),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_paymentStatus == 'released') ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.task_alt_rounded, color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Invoice Ready', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                                      SizedBox(height: 2),
                                      Text('TF-8821 · CA 456-789 · 8 Mar 2026', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(12)),
                              child: const Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Labour & Parts', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                      Text('£165.00', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Platform Fee (12%)', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                      Text('£20.00', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total Charged', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                                      Text('£185.00', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download PDF'))),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.download_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text('DOWNLOAD INVOICE (PDF)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Invoice ref: TF-INV-20260308-8821',
                                style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.85), fontSize: 9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_paymentStatus == 'released' && !_ratingSubmitted) ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => setState(() {
                          _ratingOpen = true;
                          _ratingSubmitted = false;
                          _ratingValue = 0;
                          _ratingComment.clear();
                        }),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.30)),
                          backgroundColor: AppColors.card,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star_rounded, size: 18, color: AppColors.primary),
                                Icon(Icons.star_rounded, size: 18, color: AppColors.primary),
                                Icon(Icons.star_rounded, size: 18, color: AppColors.primary),
                                Icon(Icons.star_rounded, size: 18, color: AppColors.primary),
                                Icon(Icons.star_rounded, size: 18, color: AppColors.primary),
                              ],
                            ),
                            SizedBox(width: 10),
                            Text('RATE YOUR MECHANIC', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ],
                    if (_paymentStatus == 'released' && _ratingSubmitted) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.green.withValues(alpha: 0.30)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppColors.green, size: 18),
                            SizedBox(width: 10),
                            Expanded(child: Text('Review submitted — thank you!', style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (_mechanicStartedJourney && _paymentStatus != 'released')
                      FilledButton(
                        onPressed: () => setState(() => _contactOpen = true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 20),
                            SizedBox(width: 10),
                            Text('CONTACT MECHANIC', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8)),
                          ],
                        ),
                      ),
                    if (_paymentStatus != 'released') ...[
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () => setState(() => _cancelOpen = true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.red,
                          side: BorderSide(color: AppColors.red.withValues(alpha: 0.30)),
                          backgroundColor: AppColors.red.withValues(alpha: 0.05),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _detailHasFee ? 'Cancel Job · $_detailFee fee (10%)' : 'Cancel Job — Free',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_cancelOpen) _cancelSheet(),
        if (_contactOpen) _contactSheet(),
        if (_ratingOpen) _ratingSheet(),
      ],
    );
  }

  Widget _payRow(String label, String value, {bool brightValue = false, bool mutedValue = false, bool valueYellow = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              color: valueYellow
                  ? AppColors.primary
                  : valueColor ?? (mutedValue ? AppColors.textMuted : (brightValue ? Colors.white : AppColors.textSecondary)),
              fontSize: 12,
              fontWeight: brightValue || valueYellow ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FleetDetailBottomOverlay extends StatelessWidget {
  const _FleetDetailBottomOverlay({required this.child, this.onBarrierTap, this.align = Alignment.bottomCenter});

  final Widget child;
  final VoidCallback? onBarrierTap;
  final Alignment align;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.85),
        child: GestureDetector(
          onTap: onBarrierTap,
          behavior: HitTestBehavior.opaque,
          child: Align(
            alignment: align,
            child: GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ),
        ),
      ),
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
    required this.vm,
    required this.onEdit,
    required this.onVehicles,
    required this.onPayment,
    required this.onHelp,
    required this.onLogout,
  });

  final FleetViewModel vm;
  final VoidCallback onEdit;
  final VoidCallback onVehicles;
  final VoidCallback onPayment;
  final VoidCallback onHelp;
  final VoidCallback onLogout;

  static const Color _profileBg = Color(0xFF080808);
  static const Color _rowLabel = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    if (vm.meProfileLoading && vm.meProfile == null) {
      return const ColoredBox(
        color: _profileBg,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (vm.meProfileError != null && vm.meProfile == null) {
      return ColoredBox(
        color: _profileBg,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vm.meProfileError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 13),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: vm.loadMeProfile,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final p = vm.meProfile;
    if (p == null) {
      return ColoredBox(
        color: _profileBg,
        child: Center(
          child: Text(
            'No profile data',
            style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.9), fontSize: 13),
          ),
        ),
      );
    }

    return ColoredBox(
      color: _profileBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (vm.meProfileLoading) ...[
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Color(0xFF1A1A1A),
              color: AppColors.primary,
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.20),
                        blurRadius: 30,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    p.avatarInitials,
                    style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  p.headerTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.2, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  p.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.85), fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _profileSection(
                  'Company Details',
                  [
                    ('Company Name', p.companyName),
                    ('Reg Number', p.regNumber),
                    ('VAT Number', p.vatNumber),
                    ('Fleet Size', p.fleetSize),
                  ],
                ),
                const SizedBox(height: 12),
                _profileSection(
                  'Contact Person',
                  [
                    ('Name', p.contactName),
                    ('Role', p.contactRole),
                    ('Phone', p.contactPhone),
                    ('Email', p.email),
                  ],
                ),
                const SizedBox(height: 12),
                _profileSection(
                  'Billing & Payment',
                  [
                    ('Card Number', p.cardDisplay),
                    ('Expiry', p.expiryDisplay),
                    ('CCV', '•••'),
                    ('Billing Address', p.billingAddress),
                  ],
                ),
                const SizedBox(height: 16),
                Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.edit_outlined, color: Colors.black, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Edit Profile',
                            style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _profileActionTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Payment Methods',
                  subtitle: 'Manage your cards & billing',
                  onTap: onPayment,
                ),
                const SizedBox(height: 12),
                _profileActionTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'My Fleet',
                  subtitle: 'Manage your vehicles',
                  onTap: onVehicles,
                ),
                const SizedBox(height: 12),
                _profileActionTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'Send a message to the TruckFix team',
                  onTap: onHelp,
                ),
                const SizedBox(height: 12),
                Material(
                  color: AppColors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onLogout,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.red.withValues(alpha: 0.20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout_rounded, color: AppColors.red, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(color: AppColors.red, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Account created · 07 Mar 2026 · TruckFix v2.4.1',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.65), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileSection(String title, List<(String, String)> rows) {
    return Container(
      decoration: BoxDecoration(
        color: _FleetDashTheme.statCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _profileRow(rows[i].$1, rows[i].$2),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: _rowLabel, fontSize: 12, height: 1.25),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, height: 1.25),
          ),
        ),
      ],
    );
  }

  Widget _profileActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _FleetDashTheme.statCardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E1E)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.75), fontSize: 10, height: 1.2),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted.withValues(alpha: 0.8), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _FleetEditProfile extends StatefulWidget {
  const _FleetEditProfile({
    required this.onSave,
    required this.onCancel,
    this.openedForPostJob = false,
  });

  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool openedForPostJob;

  @override
  State<_FleetEditProfile> createState() => _FleetEditProfileState();
}

class _FleetEditProfileState extends State<_FleetEditProfile> {
  static const _fleetSizes = [
    '21–50 vehicles',
    '1–5 vehicles',
    '6–20 vehicles',
    '51–100 vehicles',
    '100+ vehicles',
  ];

  late final TextEditingController _companyName;
  late final TextEditingController _regNumber;
  late final TextEditingController _vatNumber;
  late String _fleetSize;

  late final TextEditingController _fullName;
  late final TextEditingController _role;
  late final TextEditingController _phone;
  late final TextEditingController _email;

  late final TextEditingController _cardNumber;
  late final TextEditingController _expiry;
  late final TextEditingController _ccv;
  late final TextEditingController _billingAddress;

  static const Color _bg = Color(0xFF080808);
  static const Color _fieldFill = Color(0xFF111111);
  static const Color _labelGray = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _companyName = TextEditingController(text: 'Logistix Transport (Pty) Ltd');
    _regNumber = TextEditingController(text: '2019/223456/07');
    _vatNumber = TextEditingController(text: '4120889456');
    _fleetSize = _fleetSizes.first;

    _fullName = TextEditingController(text: 'John Khumalo');
    _role = TextEditingController(text: 'Fleet Manager');
    _phone = TextEditingController(text: '+44 7712 345 678');
    _email = TextEditingController(text: 'john@logistix.co.za');

    _cardNumber = TextEditingController(text: '4242  4242  4242  4242');
    _expiry = TextEditingController(text: '09 / 28');
    _ccv = TextEditingController(text: '');
    _billingAddress = TextEditingController(text: '123 Logistics Ave, Johannesburg');
  }

  @override
  void dispose() {
    _companyName.dispose();
    _regNumber.dispose();
    _vatNumber.dispose();
    _fullName.dispose();
    _role.dispose();
    _phone.dispose();
    _email.dispose();
    _cardNumber.dispose();
    _expiry.dispose();
    _ccv.dispose();
    _billingAddress.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.85)),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.60)),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _fieldLabel(String label, {String? optionalSuffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: _labelGray,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
          children: [
            TextSpan(text: label.toUpperCase()),
            if (optionalSuffix != null)
              TextSpan(
                text: optionalSuffix,
                style: TextStyle(
                  color: AppColors.textHint.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _fieldDecoration(hint: hintText).copyWith(suffixIcon: suffix),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 12),
              child: Row(
                children: [
                  _fleetCircleBackButton(onPressed: widget.onCancel),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.openedForPostJob ? 'POST JOB' : 'FLEET OPERATOR',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.openedForPostJob ? 'Complete your profile' : 'Edit Profile',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (widget.openedForPostJob) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Save to return to Post Job and finish your request.',
                            style: TextStyle(
                              color: AppColors.textMuted.withValues(alpha: 0.95),
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader('Company Details'),
                    const SizedBox(height: 12),
                    _fieldLabel('Company Name'),
                    _textField(controller: _companyName),
                    const SizedBox(height: 12),
                    _fieldLabel('Reg Number'),
                    _textField(controller: _regNumber),
                    const SizedBox(height: 12),
                    _fieldLabel('VAT Number'),
                    _textField(controller: _vatNumber),
                    const SizedBox(height: 12),
                    _fieldLabel('Fleet Size ', optionalSuffix: '(optional)'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _fieldFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _fleetSize,
                          isExpanded: true,
                          dropdownColor: _fieldFill,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          icon: Icon(Icons.expand_more_rounded, color: AppColors.textMuted.withValues(alpha: 0.9)),
                          items: _fleetSizes
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _fleetSize = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 20),
                    _sectionHeader('Contact Person'),
                    const SizedBox(height: 12),
                    _fieldLabel('Full Name'),
                    _textField(controller: _fullName),
                    const SizedBox(height: 12),
                    _fieldLabel('Role / Title'),
                    _textField(controller: _role),
                    const SizedBox(height: 12),
                    _fieldLabel('Phone'),
                    _textField(controller: _phone, keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _fieldLabel('Email'),
                    _textField(controller: _email, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 20),
                    _sectionHeader('Billing & Payment'),
                    const SizedBox(height: 12),
                    _fieldLabel('Card Number'),
                    _textField(
                      controller: _cardNumber,
                      keyboardType: TextInputType.number,
                      suffix: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.lock_outline_rounded, color: AppColors.textHint.withValues(alpha: 0.75), size: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _fieldLabel('Expiry'),
                              _textField(controller: _expiry),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _fieldLabel('CCV'),
                              _textField(
                                controller: _ccv,
                                obscure: true,
                                hintText: '•••',
                                suffix: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Icon(Icons.lock_outline_rounded, color: AppColors.textHint.withValues(alpha: 0.75), size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _fieldLabel('Billing Address'),
                    _textField(controller: _billingAddress),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textHint.withValues(alpha: 0.8)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Card details are encrypted and stored securely. TruckFix never stores raw card data.',
                            style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.85), fontSize: 10, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8 + MediaQuery.paddingOf(context).bottom),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: widget.onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'SAVE CHANGES',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.95),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

Widget _fleetCircleBackButton({required VoidCallback onPressed}) {
  return Material(
    color: const Color(0xFF1A1A1A),
    shape: const CircleBorder(),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onPressed,
      child: const SizedBox(
        width: 40,
        height: 40,
        child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
      ),
    ),
  );
}

class _FleetVehiclesOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FleetViewModel>();
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
              child: Row(
                children: [
                  _fleetCircleBackButton(onPressed: vm.closeVehicles),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'My Fleet',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.2),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add vehicle (demo)')),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      '+ ADD',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: vm.vehicles.map((v) => _FleetVehicleListCard(vehicle: v, onTap: () => vm.selectVehicle(v))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FleetVehicleListCard extends StatelessWidget {
  const _FleetVehicleListCard({required this.vehicle, required this.onTap});

  final Vehicle vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badge = vehicle.categoryBadge ?? (vehicle.type != null ? vehicle.type!.toUpperCase() : 'VEHICLE');
    final last = vehicle.lastService ?? '—';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        vehicle.plate,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.65)),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  vehicle.label,
                  style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last Service',
                      style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      last,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FleetPayCardRow {
  _FleetPayCardRow({required this.brand, required this.last4, required this.expiry});

  final String brand;
  final String last4;
  final String expiry;
}

class _FleetPaymentOverlay extends StatefulWidget {
  @override
  State<_FleetPaymentOverlay> createState() => _FleetPaymentOverlayState();
}

class _FleetPaymentOverlayState extends State<_FleetPaymentOverlay> {
  late List<_FleetPayCardRow> _cards;
  int _defaultIndex = 0;
  bool _showAddCard = false;

  final _addCardFormKey = GlobalKey<FormState>();
  late final TextEditingController _addCardNumber;
  late final TextEditingController _addExpiry;
  late final TextEditingController _addCvc;
  late final TextEditingController _addCardholder;

  static const _fieldFill = Color(0xFF1A1A1A);
  static const _fieldBorder = Color(0xFF2A2A2A);

  @override
  void initState() {
    super.initState();
    _cards = [
      _FleetPayCardRow(brand: 'Visa', last4: '4242', expiry: '12/26'),
      _FleetPayCardRow(brand: 'Mastercard', last4: '8888', expiry: '09/27'),
    ];
    _addCardNumber = TextEditingController();
    _addExpiry = TextEditingController();
    _addCvc = TextEditingController();
    _addCardholder = TextEditingController();
  }

  @override
  void dispose() {
    _addCardNumber.dispose();
    _addExpiry.dispose();
    _addCvc.dispose();
    _addCardholder.dispose();
    super.dispose();
  }

  String _cardDigitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  String _inferCardBrand(String digits) {
    if (digits.isEmpty) return 'Card';
    switch (digits[0]) {
      case '4':
        return 'Visa';
      case '5':
        return 'Mastercard';
      case '3':
        return 'Amex';
      case '6':
        return 'Discover';
      default:
        return 'Card';
    }
  }

  InputDecoration _addCardDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.9), fontSize: 14),
      filled: true,
      fillColor: _fieldFill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _fieldBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.55), width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.red.withValues(alpha: 0.7), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.red, width: 1),
      ),
    );
  }

  Widget _addCardFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  void _saveNewCard() {
    if (_addCardFormKey.currentState?.validate() != true) return;
    final digits = _cardDigitsOnly(_addCardNumber.text);
    final last4 = digits.substring(digits.length - 4);
    final brand = _inferCardBrand(digits);
    final expiry = _addExpiry.text.trim();
    setState(() {
      _cards.add(_FleetPayCardRow(brand: brand, last4: last4, expiry: expiry));
      if (_cards.length == 1) _defaultIndex = 0;
      _showAddCard = false;
    });
    _addCardNumber.clear();
    _addExpiry.clear();
    _addCvc.clear();
    _addCardholder.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card saved')));
  }

  void _removeAt(int i) {
    setState(() {
      _cards.removeAt(i);
      if (_cards.isEmpty) {
        _defaultIndex = 0;
      } else if (_defaultIndex >= _cards.length) {
        _defaultIndex = _cards.length - 1;
      } else if (i < _defaultIndex) {
        _defaultIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FleetViewModel>();

    return Material(
      color: Colors.black,
      child: SafeArea(
        child: _showAddCard ? _buildAddCardScreen() : _buildPaymentListScreen(vm),
      ),
    );
  }

  Widget _buildPaymentListScreen(FleetViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
          child: Row(
            children: [
              _fleetCircleBackButton(onPressed: vm.closePayment),
              const SizedBox(width: 12),
              const Text(
                'Payment Methods',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.2),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              for (var i = 0; i < _cards.length; i++) ...[
                _FleetPaymentCardTile(
                  row: _cards[i],
                  isDefault: i == _defaultIndex,
                  onSetDefault: _cards.length > 1 && i != _defaultIndex ? () => setState(() => _defaultIndex = i) : null,
                  onRemove: () => _removeAt(i),
                ),
                const SizedBox(height: 12),
              ],
              Material(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => setState(() => _showAddCard = true),
                  borderRadius: BorderRadius.circular(12),
                  child: CustomPaint(
                    painter: _FleetDashedBorderPainter(
                      color: const Color(0xFF4B5563),
                      strokeWidth: 1.5,
                      radius: 12,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: AppColors.textMuted, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'ADD NEW CARD',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddCardScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
          child: Row(
            children: [
              _fleetCircleBackButton(onPressed: () => setState(() => _showAddCard = false)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Payment Methods',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.2),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.textMuted, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'ADD NEW CARD',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Form(
                  key: _addCardFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'NEW CARD DETAILS',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _addCardFieldLabel('CARD NUMBER'),
                      TextFormField(
                        controller: _addCardNumber,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(19)],
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _addCardDecoration('1234 5678 9012 3456'),
                        validator: (v) {
                          final d = _cardDigitsOnly(v ?? '');
                          if (d.length < 15) return 'Enter a valid card number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _addCardFieldLabel('EXPIRY'),
                                TextFormField(
                                  controller: _addExpiry,
                                  keyboardType: TextInputType.datetime,
                                  inputFormatters: [_FleetExpiryInputFormatter(), LengthLimitingTextInputFormatter(5)],
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: _addCardDecoration('MM/YY'),
                                  validator: (v) {
                                    final t = (v ?? '').trim();
                                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(t)) return 'Use MM/YY';
                                    final mm = int.tryParse(t.substring(0, 2));
                                    if (mm == null || mm < 1 || mm > 12) return 'Invalid month';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _addCardFieldLabel('CVC'),
                                TextFormField(
                                  controller: _addCvc,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: _addCardDecoration('123'),
                                  validator: (v) {
                                    final l = (v ?? '').trim().length;
                                    if (l < 3 || l > 4) return 'Invalid CVC';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _addCardFieldLabel('CARDHOLDER NAME'),
                      TextFormField(
                        controller: _addCardholder,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _addCardDecoration('John Smith'),
                        validator: (v) {
                          if ((v ?? '').trim().length < 2) return 'Enter cardholder name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saveNewCard,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            'SAVE CARD',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.9),
                          ),
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
    );
  }
}

/// Inserts `/` after MM when typing expiry (MM/YY).
class _FleetExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var t = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (t.length > 4) t = t.substring(0, 4);
    final buf = StringBuffer();
    for (var i = 0; i < t.length; i++) {
      if (i == 2) buf.write('/');
      buf.write(t[i]);
    }
    final s = buf.toString();
    return TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }
}

class _FleetDashedBorderPainter extends CustomPainter {
  _FleetDashedBorderPainter({required this.color, required this.strokeWidth, required this.radius});

  final Color color;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()..addRRect(r);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final next = d + 6;
        final extract = metric.extractPath(d, next > metric.length ? metric.length : next);
        canvas.drawPath(extract, paint);
        d = next + 4;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FleetDashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth || oldDelegate.radius != radius;
}

class _FleetPaymentCardTile extends StatelessWidget {
  const _FleetPaymentCardTile({
    required this.row,
    required this.isDefault,
    required this.onRemove,
    this.onSetDefault,
  });

  final _FleetPayCardRow row;
  final bool isDefault;
  final VoidCallback onRemove;
  final VoidCallback? onSetDefault;

  @override
  Widget build(BuildContext context) {
    final title = '${row.brand} •••• ${row.last4}';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.credit_card_rounded, color: Colors.black, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Expires ${row.expiry}',
                            style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.9), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (isDefault)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onRemove,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.red.withValues(alpha: 0.18),
                        foregroundColor: AppColors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'REMOVE',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: onSetDefault,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A1A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Color(0xFF2A2A2A)),
                            ),
                          ),
                          child: const Text(
                            'SET DEFAULT',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          onPressed: onRemove,
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.red.withValues(alpha: 0.18),
                            foregroundColor: AppColors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'REMOVE',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (isDefault)
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.7)),
                ),
                child: const Text(
                  'DEFAULT',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FleetHelpOverlay extends StatefulWidget {
  @override
  State<_FleetHelpOverlay> createState() => _FleetHelpOverlayState();
}

class _FleetHelpOverlayState extends State<_FleetHelpOverlay> {
  String? _category;
  final _message = TextEditingController();
  bool _sent = false;

  static const _categories = <(String id, String label, IconData icon)>[
    ('job', 'Job / Booking', Icons.bolt_rounded),
    ('payment', 'Payment / Invoice', Icons.credit_card_rounded),
    ('account', 'Account & Profile', Icons.person_rounded),
    ('mechanic', 'Mechanic Issue', Icons.build_rounded),
    ('other', 'Other', Icons.help_outline_rounded),
  ];

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FleetViewModel>();

    if (_sent) {
      return Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: vm.closeHelp,
                behavior: HitTestBehavior.opaque,
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.85)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                color: const Color(0xFF0E0E0E),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border2)),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.paddingOf(context).bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(99)),
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.green.withValues(alpha: 0.30)),
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 36),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Message Sent!',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Our support team will respond within 24 hours via your registered email address.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: vm.closeHelp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'DONE',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
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
      );
    }

    final canSend = _category != null && _message.text.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: vm.closeHelp,
              behavior: HitTestBehavior.opaque,
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.85)),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {},
              child: Material(
                color: const Color(0xFF0E0E0E),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border2)),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(99)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Help & Support',
                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'We usually reply within 24 hours',
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: vm.closeHelp,
                              style: IconButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A)),
                              icon: Icon(Icons.close_rounded, color: AppColors.textMuted.withValues(alpha: 0.9), size: 20),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "WHAT'S THIS ABOUT?",
                                style: TextStyle(
                                  color: AppColors.textMuted.withValues(alpha: 0.95),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _helpCatTile(0)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _helpCatTile(1)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _helpCatTile(2)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _helpCatTile(3)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _helpCatTile(4, fullWidth: true),
                              const SizedBox(height: 20),
                              Text(
                                'YOUR MESSAGE',
                                style: TextStyle(
                                  color: AppColors.textMuted.withValues(alpha: 0.95),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _message,
                                onChanged: (_) => setState(() {}),
                                maxLines: 5,
                                style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.35),
                                decoration: InputDecoration(
                                  hintText: 'Describe your issue or question in as much detail as possible...',
                                  hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.85)),
                                  filled: true,
                                  fillColor: AppColors.card2,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.40)),
                                  ),
                                  contentPadding: const EdgeInsets.all(14),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sent from: john@logistix.co.za · Fleet Operator',
                                style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.75), fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.paddingOf(context).bottom),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: AppColors.border)),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: canSend
                                    ? () => setState(() {
                                          _sent = true;
                                        })
                                    : null,
                                icon: const Icon(Icons.send_rounded, size: 18),
                                label: const Text(
                                  'SEND MESSAGE',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.30),
                                  disabledForegroundColor: Colors.black.withValues(alpha: 0.35),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: vm.closeHelp,
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _helpCatTile(int index, {bool fullWidth = false}) {
    final c = _categories[index];
    final sel = _category == c.$1;
    final child = Material(
      color: sel ? AppColors.primary.withValues(alpha: 0.08) : AppColors.card2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _category = c.$1),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? AppColors.primary.withValues(alpha: 0.50) : const Color(0xFF1E1E1E)),
          ),
          child: Row(
            children: [
              Icon(c.$3, size: 18, color: sel ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c.$2,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: sel ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.95),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (fullWidth) return child;
    return child;
  }
}
