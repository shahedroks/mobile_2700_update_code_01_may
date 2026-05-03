import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../viewmodel/company_viewmodel.dart';
import 'company_management_screens.dart';

class CompanyAppShell extends StatelessWidget {
  const CompanyAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompanyViewModel(),
      child: const _CompanyScaffold(),
    );
  }
}

class _CompanyScaffold extends StatelessWidget {
  const _CompanyScaffold();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompanyViewModel>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Expanded(child: _CompanyBody()),
          _CompanyTabBar(vm: vm),
        ],
      ),
    );
  }
}

class _CompanyTabBar extends StatelessWidget {
  const _CompanyTabBar({required this.vm});

  final CompanyViewModel vm;

  @override
  Widget build(BuildContext context) {
    final active = vm.bottomResolved;
    Widget tab(String id, IconData icon, String label, {int? badge}) {
      final on = active == id;
      return Expanded(
        child: InkWell(
          onTap: () => vm.setScreen(id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: on ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 18, color: on ? Colors.black : AppColors.textMuted),
                    ),
                    if (badge != null && badge > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.bg, width: 1),
                          ),
                          constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                          alignment: Alignment.center,
                          child: Text(
                            '$badge',
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, height: 1),
                          ),
                        ),
                      ),
                  ],
                ),
                Text(label, style: TextStyle(fontSize: 8, color: on ? AppColors.primary : AppColors.textHint)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(color: AppColors.bg, border: Border(top: BorderSide(color: AppColors.border))),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            tab('company-dashboard', Icons.dashboard_outlined, 'Dashboard'),
            tab('company-job-feed', Icons.search, 'Feed'),
            tab('company-jobs', Icons.work_outline, 'Jobs', badge: 2),
            tab('company-team', Icons.groups_outlined, 'Team'),
            tab('company-profile', Icons.person_outline, 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _CompanyBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompanyViewModel>();
    switch (vm.screen) {
      case 'company-dashboard':
        return _coDashboard(context);
      case 'company-job-feed':
        return const _CompanyJobFeedView();
      case 'company-jobs':
        return const CompanyJobsManagementView();
      case 'company-team':
        return const CompanyTeamManagementView();
      case 'company-earnings':
        return CompanyEarningsView(onBack: () => vm.setScreen('company-profile'));
      case 'company-profile':
        return const CompanyProfileFullView();
      case 'company-edit-profile':
        return _coEdit(() => vm.setScreen('company-profile'));
      default:
        return _coDashboard(context);
    }
  }

  Widget _coDashboard(BuildContext context) {
    final vm = context.read<CompanyViewModel>();
    const headerBg = Color(0xFF0F0F0F);
    const blueAccent = Color(0xFF60A5FA);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: const BoxDecoration(
            color: headerBg,
            border: Border(bottom: BorderSide(color: AppColors.border2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Swift Mechanics Ltd',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                    ),
                    SizedBox(height: 4),
                    Text('Company Dashboard', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.45), blurRadius: 6)],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '4 Active Mechanics',
                    style: TextStyle(color: AppColors.green.withValues(alpha: 0.95), fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _companyDashMetric(
                      borderColor: AppColors.primary.withValues(alpha: 0.35),
                      labelColor: AppColors.primary,
                      icon: Icons.work_outline_rounded,
                      label: 'Active Jobs',
                      value: '6',
                      sub: '2 unassigned',
                      subColor: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _companyDashMetric(
                      borderColor: AppColors.green.withValues(alpha: 0.35),
                      labelColor: AppColors.green,
                      icon: Icons.groups_outlined,
                      label: 'Mechanics',
                      value: '4',
                      sub: '3 online',
                      subColor: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _companyDashMetric(
                      borderColor: blueAccent.withValues(alpha: 0.35),
                      labelColor: blueAccent,
                      icon: Icons.payments_outlined,
                      label: 'This Month',
                      value: '£18.4k',
                      sub: '+12% vs last',
                      subColor: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _companyDashMetric(
                      borderColor: AppColors.orange.withValues(alpha: 0.35),
                      labelColor: AppColors.orange,
                      icon: Icons.star_rounded,
                      label: 'Avg Rating',
                      value: '4.8',
                      sub: '156 reviews',
                      subColor: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.65)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '2 Jobs Need Assignment',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Assign mechanics to new job requests',
                                style: TextStyle(
                                  color: AppColors.textSecondary.withValues(alpha: 0.95),
                                  fontSize: 12,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => vm.setScreen('company-jobs'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Assign Now',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _companyQuickAction(
                      icon: Icons.groups_outlined,
                      iconColor: AppColors.primary,
                      title: 'Manage Team',
                      subtitle: '4 mechanics',
                      onTap: () => vm.setScreen('company-team'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _companyQuickAction(
                      icon: Icons.person_add_alt_1_outlined,
                      iconColor: AppColors.green,
                      title: 'Add Mechanic',
                      subtitle: 'Send invite',
                      onTap: () => vm.setScreen('company-team'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'RECENT ACTIVITY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: headerBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border2),
                ),
                child: Column(
                  children: [
                    _companyActivityRow(
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.green,
                      title: 'Job completed',
                      detail: 'TF-8820 by John Smith',
                      time: '5 min ago',
                      showDivider: true,
                    ),
                    _companyActivityRow(
                      icon: Icons.work_outline_rounded,
                      iconColor: AppColors.primary,
                      title: 'New job assigned',
                      detail: 'TF-8822 to Mike Johnson',
                      time: '25 min ago',
                      showDivider: true,
                    ),
                    _companyActivityRow(
                      icon: Icons.circle_outlined,
                      iconColor: blueAccent,
                      title: 'Mechanic online',
                      detail: 'Dave Wilson started shift',
                      time: '1 hr ago',
                      showDivider: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _coEdit(VoidCallback onDone) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(onPressed: onDone, icon: const Icon(Icons.close)),
            const Text('Edit company profile'),
          ],
        ),
        ElevatedButton(onPressed: onDone, child: const Text('Save')),
      ],
    );
  }

  Widget _companyDashMetric({
    required Color borderColor,
    required Color labelColor,
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color subColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: labelColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(color: labelColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, height: 1)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(color: subColor, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _companyQuickAction({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _companyActivityRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String detail,
    required String time,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(detail, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Text(time, style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, thickness: 1, color: AppColors.border),
      ],
    );
  }
}

// ─── Job Feed (`CompanyJobFeed` / check.tsx) ─────────────────────────────────

enum _CoFeedUrgency { urgent, high, medium, low }

class _CoFeedAvailableJob {
  const _CoFeedAvailableJob({
    required this.id,
    required this.vehicle,
    required this.issue,
    required this.urgency,
    required this.location,
    required this.distance,
    required this.time,
    required this.fleetRating,
  });

  final String id;
  final String vehicle;
  final String issue;
  final _CoFeedUrgency urgency;
  final String location;
  final String distance;
  final String time;
  final double fleetRating;
}

class _CoFeedMyQuote {
  const _CoFeedMyQuote({
    required this.id,
    required this.vehicle,
    required this.issue,
    required this.status,
    required this.quote,
    required this.location,
    required this.time,
  });

  final String id;
  final String vehicle;
  final String issue;
  final String status;
  final String quote;
  final String location;
  final String time;
}

const List<_CoFeedAvailableJob> _kCoAvailableJobs = [
  _CoFeedAvailableJob(
    id: 'TF-8901',
    vehicle: 'DAF XF',
    issue: 'Engine warning light',
    urgency: _CoFeedUrgency.urgent,
    location: 'M1 Services',
    distance: '8 miles',
    time: '5 min ago',
    fleetRating: 4.7,
  ),
  _CoFeedAvailableJob(
    id: 'TF-8902',
    vehicle: 'Scania R450',
    issue: 'Brake system fault',
    urgency: _CoFeedUrgency.high,
    location: 'Birmingham',
    distance: '12 miles',
    time: '18 min ago',
    fleetRating: 4.9,
  ),
  _CoFeedAvailableJob(
    id: 'TF-8903',
    vehicle: 'Volvo FH16',
    issue: 'Coolant leak',
    urgency: _CoFeedUrgency.medium,
    location: 'Manchester',
    distance: '25 miles',
    time: '45 min ago',
    fleetRating: 4.5,
  ),
  _CoFeedAvailableJob(
    id: 'TF-8904',
    vehicle: 'Mercedes Actros',
    issue: 'Electrical fault',
    urgency: _CoFeedUrgency.low,
    location: 'Leeds',
    distance: '32 miles',
    time: '1 hr ago',
    fleetRating: 4.8,
  ),
  _CoFeedAvailableJob(
    id: 'TF-8905',
    vehicle: 'MAN TGX',
    issue: 'Flat tyre + inspection',
    urgency: _CoFeedUrgency.high,
    location: 'Sheffield',
    distance: '18 miles',
    time: '23 min ago',
    fleetRating: 4.6,
  ),
];

const List<_CoFeedMyQuote> _kCoMyQuotes = [
  _CoFeedMyQuote(
    id: 'TF-8898',
    vehicle: 'DAF CF',
    issue: 'Oil leak',
    status: 'pending',
    quote: '£320',
    location: 'M6 Services',
    time: '2 hrs ago',
  ),
  _CoFeedMyQuote(
    id: 'TF-8899',
    vehicle: 'Iveco Stralis',
    issue: 'Battery dead',
    status: 'accepted',
    quote: '£180',
    location: 'Birmingham',
    time: '4 hrs ago',
  ),
  _CoFeedMyQuote(
    id: 'TF-8897',
    vehicle: 'Renault T-High',
    issue: 'Suspension fault',
    status: 'rejected',
    quote: '£540',
    location: 'Manchester',
    time: '1 day ago',
  ),
];

class _CompanyJobFeedView extends StatefulWidget {
  const _CompanyJobFeedView();

  @override
  State<_CompanyJobFeedView> createState() => _CompanyJobFeedViewState();
}

class _CompanyJobFeedViewState extends State<_CompanyJobFeedView> {
  static const Color _headerBg = Color(0xFF0F0F0F);
  static const Color _tabInactiveBg = Color(0xFF1A1A1A);
  static const Color _blueUrgent = Color(0xFF60A5FA);

  bool _availableTab = true;

  (Color bg, Color fg, Color border) _urgencyStyle(_CoFeedUrgency u) {
    switch (u) {
      case _CoFeedUrgency.urgent:
        return (AppColors.red.withValues(alpha: 0.10), AppColors.red, AppColors.red.withValues(alpha: 0.30));
      case _CoFeedUrgency.high:
        return (AppColors.orange.withValues(alpha: 0.10), AppColors.orange, AppColors.orange.withValues(alpha: 0.30));
      case _CoFeedUrgency.medium:
      case _CoFeedUrgency.low:
        return (_blueUrgent.withValues(alpha: 0.10), _blueUrgent, _blueUrgent.withValues(alpha: 0.30));
    }
  }

  String _urgencyLabel(_CoFeedUrgency u) => switch (u) {
        _CoFeedUrgency.urgent => 'URGENT',
        _CoFeedUrgency.high => 'HIGH',
        _CoFeedUrgency.medium => 'MEDIUM',
        _CoFeedUrgency.low => 'LOW',
      };

  (Color bg, Color fg, Color border) _quoteStatusStyle(String s) {
    switch (s) {
      case 'accepted':
        return (AppColors.green.withValues(alpha: 0.10), AppColors.green, AppColors.green.withValues(alpha: 0.30));
      case 'pending':
        return (AppColors.primary.withValues(alpha: 0.10), AppColors.primary, AppColors.primary.withValues(alpha: 0.30));
      default:
        return (AppColors.red.withValues(alpha: 0.10), AppColors.red, AppColors.red.withValues(alpha: 0.30));
    }
  }

  void _openQuoteSheet(_CoFeedAvailableJob job) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CoQuoteSubmitSheet(job: job, onClose: () => Navigator.pop(ctx)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: _headerBg,
              border: Border(bottom: BorderSide(color: AppColors.border2)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Job Feed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Browse & send quotes',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_kCoAvailableJobs.length}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            ' new',
                            style: TextStyle(
                              color: AppColors.primary.withValues(alpha: 0.80),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _feedTabButton(
                        label: 'Available Jobs (${_kCoAvailableJobs.length})',
                        selected: _availableTab,
                        onTap: () => setState(() => _availableTab = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _feedTabButton(
                        label: 'My Quotes (${_kCoMyQuotes.length})',
                        selected: !_availableTab,
                        onTap: () => setState(() => _availableTab = false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _availableTab ? _kCoAvailableJobs.length : _kCoMyQuotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (_availableTab) {
                  final job = _kCoAvailableJobs[i];
                  return _availableJobCard(job);
                }
                final q = _kCoMyQuotes[i];
                return _myQuoteCard(q);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedTabButton({required String label, required bool selected, required VoidCallback onTap}) {
    return Material(
      color: selected ? AppColors.primary : _tabInactiveBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? Colors.transparent : AppColors.border2),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.black : AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _availableJobCard(_CoFeedAvailableJob job) {
    final st = _urgencyStyle(job.urgency);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _headerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Text(
                          job.id,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: st.$1,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: st.$3),
                          ),
                          child: Text(
                            _urgencyLabel(job.urgency),
                            style: TextStyle(color: st.$2, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.4),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 2),
                            Text(
                              '${job.fleetRating}',
                              style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.vehicle,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.issue,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                job.time,
                style: const TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted.withValues(alpha: 0.9)),
              const SizedBox(width: 4),
              Text(job.location, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const SizedBox(width: 14),
              Icon(Icons.adjust, size: 15, color: AppColors.green.withValues(alpha: 0.95)),
              const SizedBox(width: 4),
              Text(job.distance, style: const TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _openQuoteSheet(job),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Send Quote', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _myQuoteCard(_CoFeedMyQuote q) {
    final st = _quoteStatusStyle(q.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _headerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          q.id,
                          style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: st.$1,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: st.$3),
                          ),
                          child: Text(
                            q.status.toUpperCase(),
                            style: TextStyle(color: st.$2, fontSize: 9, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(q.vehicle, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(q.issue, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                q.quote,
                style: const TextStyle(color: AppColors.green, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted.withValues(alpha: 0.9)),
              const SizedBox(width: 4),
              Text(q.location, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const SizedBox(width: 14),
              Icon(Icons.schedule_rounded, size: 15, color: AppColors.textMuted.withValues(alpha: 0.9)),
              const SizedBox(width: 4),
              Text(q.time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
          if (q.status == 'accepted') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.green.withValues(alpha: 0.30)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '✓ Quote accepted - Assign mechanic',
                      style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Assign', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CoQuoteSubmitSheet extends StatelessWidget {
  const _CoQuoteSubmitSheet({required this.job, required this.onClose});

  final _CoFeedAvailableJob job;
  final VoidCallback onClose;

  static const Color _sheetBg = Color(0xFF0F0F0F);
  static const Color _fieldBg = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _sheetBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: AppColors.border2)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Submit Quote',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${job.id} · ${job.vehicle}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: Icon(Icons.close_rounded, color: AppColors.textMuted.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border2),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _fieldBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job.issue, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${job.location} (${job.distance})',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Text('Posted ${job.time}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Quote Amount',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _fieldBg,
                        prefixText: '£ ',
                        prefixStyle: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                        hintText: '0',
                        hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.8), fontWeight: FontWeight.w900),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border2)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border2)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.45)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Estimated Arrival (minutes)',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _fieldBg,
                        hintText: '30',
                        hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.7)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border2)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border2)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.45)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Additional Notes (Optional)',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _fieldBg,
                        hintText: 'Any additional information...',
                        hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.7)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border2)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border2)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.45)),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: onClose,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Submit Quote', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
