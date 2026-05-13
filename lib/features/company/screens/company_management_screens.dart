import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/company_viewmodel.dart';

// ─── Mock data (`check.tsx` — JOBS, PENDING_REVIEW_JOBS, MECHANICS) ─────────

class _PendingJob {
  const _PendingJob({
    required this.id,
    required this.vehicle,
    required this.issue,
    required this.location,
    required this.completedAt,
    required this.mechanic,
    required this.fleet,
    required this.invoice,
  });

  final String id;
  final String vehicle;
  final String issue;
  final String location;
  final String completedAt;
  final String mechanic;
  final String fleet;
  final _Invoice invoice;
}

class _Invoice {
  const _Invoice({
    required this.callOut,
    required this.labourHours,
    required this.hourlyRate,
    required this.partsCost,
    required this.parts,
    required this.totalGross,
  });

  final double callOut;
  final double labourHours;
  final int hourlyRate;
  final double partsCost;
  final List<(String name, double cost)> parts;
  final double totalGross;
}

class _MgmtJob {
  const _MgmtJob({
    required this.id,
    required this.vehicle,
    required this.issue,
    required this.status,
    required this.urgency,
    required this.location,
    required this.time,
    required this.price,
    this.mechanic,
  });

  final String id;
  final String vehicle;
  final String issue;
  final String status;
  final String urgency;
  final String location;
  final String time;
  final String price;
  final String? mechanic;
}

const List<_PendingJob> _kPendingJobs = [
  _PendingJob(
    id: 'TF-8820',
    vehicle: 'MAN TGX',
    issue: 'Hydraulic system fault',
    location: 'M6 Services',
    completedAt: '2 hrs ago',
    mechanic: 'John Smith',
    fleet: 'Peak Haulage Ltd',
    invoice: _Invoice(
      callOut: 85,
      labourHours: 2.5,
      hourlyRate: 65,
      partsCost: 145,
      parts: [
        ('Hydraulic pump seal kit', 95),
        ('Hydraulic fluid (10L)', 50),
      ],
      totalGross: 397.50,
    ),
  ),
  _PendingJob(
    id: 'TF-8819',
    vehicle: 'Iveco Stralis',
    issue: 'Battery replacement',
    location: 'Birmingham Depot',
    completedAt: '4 hrs ago',
    mechanic: 'Mike Johnson',
    fleet: 'Swift Freight',
    invoice: _Invoice(
      callOut: 85,
      labourHours: 0.75,
      hourlyRate: 65,
      partsCost: 95,
      parts: [('Heavy-duty battery 12V', 95)],
      totalGross: 228.75,
    ),
  ),
];

const List<_MgmtJob> _kMgmtJobs = [
  _MgmtJob(
    id: 'TF-8821',
    vehicle: 'DAF XF',
    issue: 'Engine warning light',
    status: 'unassigned',
    urgency: 'high',
    location: 'M1 Services',
    time: '12 min ago',
    price: '£450',
  ),
  _MgmtJob(
    id: 'TF-8822',
    vehicle: 'Scania R450',
    issue: 'Brake system fault',
    status: 'assigned',
    urgency: 'urgent',
    location: 'Birmingham',
    time: '25 min ago',
    price: '£680',
    mechanic: 'John Smith',
  ),
  _MgmtJob(
    id: 'TF-8823',
    vehicle: 'Volvo FH16',
    issue: 'Coolant leak',
    status: 'assigned',
    urgency: 'medium',
    location: 'Manchester',
    time: '1 hr ago',
    price: '£320',
    mechanic: 'Mike Johnson',
  ),
  _MgmtJob(
    id: 'TF-8824',
    vehicle: 'Mercedes Actros',
    issue: 'Electrical fault',
    status: 'in-progress',
    urgency: 'low',
    location: 'Leeds',
    time: '2 hrs ago',
    price: '£540',
    mechanic: 'Dave Wilson',
  ),
];

class _TeamMech {
  const _TeamMech({
    required this.id,
    required this.name,
    required this.status,
    required this.rating,
    required this.activeJobs,
    required this.completed,
    required this.phone,
    required this.email,
    required this.joinedDate,
    required this.specialties,
  });

  final String id;
  final String name;
  final String status;
  final double rating;
  final int activeJobs;
  final int completed;
  final String phone;
  final String email;
  final String joinedDate;
  final List<String> specialties;
}

Widget _mechStatusDot(String status) {
  Color c;
  switch (status) {
    case 'active':
      c = AppColors.green;
      break;
    case 'busy':
      c = AppColors.orange;
      break;
    default:
      c = AppColors.textHint;
  }
  return Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      color: c,
      shape: BoxShape.circle,
      boxShadow: status == 'active' ? [BoxShadow(color: AppColors.green.withValues(alpha: 0.45), blurRadius: 6)] : null,
    ),
  );
}

const List<_TeamMech> _kMechanics = [
  _TeamMech(
    id: 'M-001',
    name: 'John Smith',
    status: 'active',
    rating: 4.8,
    activeJobs: 2,
    completed: 45,
    phone: '07700 900123',
    email: 'john.smith@example.com',
    joinedDate: 'Jan 2024',
    specialties: ['Engine Repair', 'Diagnostics', 'Brake Systems'],
  ),
  _TeamMech(
    id: 'M-002',
    name: 'Mike Johnson',
    status: 'active',
    rating: 4.9,
    activeJobs: 1,
    completed: 38,
    phone: '07700 900456',
    email: 'mike.johnson@example.com',
    joinedDate: 'Mar 2024',
    specialties: ['Electrical', 'Air Systems', 'Transmission'],
  ),
  _TeamMech(
    id: 'M-003',
    name: 'Dave Wilson',
    status: 'busy',
    rating: 4.7,
    activeJobs: 3,
    completed: 52,
    phone: '07700 900789',
    email: 'dave.wilson@example.com',
    joinedDate: 'Nov 2023',
    specialties: ['Suspension', 'Steering', 'Tyre Services'],
  ),
  _TeamMech(
    id: 'M-004',
    name: 'Tom Brown',
    status: 'offline',
    rating: 4.6,
    activeJobs: 0,
    completed: 29,
    phone: '07700 900321',
    email: 'tom.brown@example.com',
    joinedDate: 'May 2024',
    specialties: ['Hydraulics', 'Cooling Systems', 'General Service'],
  ),
];

// ─── Job Management (`CompanyJobs` / check.tsx) ──────────────────────────────

class CompanyJobsManagementView extends StatefulWidget {
  const CompanyJobsManagementView({super.key});

  @override
  State<CompanyJobsManagementView> createState() => _CompanyJobsManagementViewState();
}

class _CompanyJobsManagementViewState extends State<CompanyJobsManagementView> {
  static const Color _headerBg = Color(0xFF0F0F0F);
  static const Color _chipInactive = Color(0xFF1A1A1A);
  static const Color _blueUrgent = Color(0xFF60A5FA);

  String _filter = 'All';
  _MgmtJob? _assignJob;
  String? _selectedMechanicId;

  static const _filters = ['All', 'Pending Review', 'Unassigned', 'Assigned', 'In Progress'];

  bool _showPendingList() => _filter == 'All' || _filter == 'Pending Review';

  bool _mgmtMatches(_MgmtJob j) {
    switch (_filter) {
      case 'All':
        return true;
      case 'Pending Review':
        return false;
      case 'Unassigned':
        return j.status == 'unassigned';
      case 'Assigned':
        return j.status == 'assigned';
      case 'In Progress':
        return j.status == 'in-progress';
      default:
        return true;
    }
  }

  (Color bg, Color fg, Color bd) _jobUrgency(String u) {
    switch (u) {
      case 'urgent':
        return (AppColors.red.withValues(alpha: 0.10), AppColors.red, AppColors.red.withValues(alpha: 0.30));
      case 'high':
        return (AppColors.orange.withValues(alpha: 0.10), AppColors.orange, AppColors.orange.withValues(alpha: 0.30));
      default:
        return (_blueUrgent.withValues(alpha: 0.10), _blueUrgent, _blueUrgent.withValues(alpha: 0.30));
    }
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
                            'Job Management',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                          ),
                          SizedBox(height: 4),
                          Text('Assign & track jobs', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
                            '${_kPendingJobs.length}',
                            style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            ' pending',
                            style: TextStyle(color: AppColors.primary.withValues(alpha: 0.80), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final f in _filters) ...[
                        if (f != _filters.first) const SizedBox(width: 8),
                        _filterChip(
                          label: f,
                          selected: _filter == f,
                          badge: f == 'Pending Review' ? _kPendingJobs.length : null,
                          onTap: () => setState(() => _filter = f),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_showPendingList())
                  ..._kPendingJobs.map((j) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _pendingReviewCard(j),
                      )),
                ..._kMgmtJobs.where(_mgmtMatches).map(
                      (j) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _regularJobCard(j),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required bool selected, required VoidCallback onTap, int? badge}) {
    return Material(
      color: selected ? AppColors.primary : _chipInactive,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? Colors.transparent : AppColors.border2),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.black : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (badge != null && badge > 0)
                Positioned(
                  right: -14,
                  top: -14,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                    child: Text(
                      '$badge',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, height: 1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pendingReviewCard(_PendingJob job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _headerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(job.id, style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
                ),
                child: const Text(
                  'PENDING REVIEW',
                  style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(job.vehicle, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(job.issue, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted.withValues(alpha: 0.9)),
              const SizedBox(width: 4),
              Text(job.location, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const SizedBox(width: 14),
              Icon(Icons.schedule_rounded, size: 15, color: AppColors.textMuted.withValues(alpha: 0.9)),
              const SizedBox(width: 4),
              Text('Completed ${job.completedAt}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _chipInactive,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border2),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_rounded, color: AppColors.green.withValues(alpha: 0.95), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.mechanic, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('Completed job', style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.85), fontSize: 10)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '£${job.invoice.totalGross.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    Text('Total invoice', style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.85), fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _showInvoiceSheet(context, job),
            icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.black),
            label: const Text('Review & Approve Invoice', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _regularJobCard(_MgmtJob job) {
    final st = _jobUrgency(job.urgency);
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
                        Text(job.id, style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: st.$1,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: st.$3),
                          ),
                          child: Text(
                            job.urgency.toUpperCase(),
                            style: TextStyle(color: st.$2, fontSize: 9, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(job.vehicle, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(job.issue, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Text(job.price, style: const TextStyle(color: AppColors.green, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted.withValues(alpha: 0.9)),
              const SizedBox(width: 4),
              Text(job.location, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const SizedBox(width: 14),
              Icon(Icons.schedule_rounded, size: 15, color: AppColors.textMuted.withValues(alpha: 0.9)),
              const SizedBox(width: 4),
              Text(job.time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          if (job.status == 'unassigned')
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _assignJob = job;
                  _selectedMechanicId = null;
                });
                _showAssignSheet(context);
              },
              icon: const Icon(Icons.person_add_alt_1_outlined, size: 18, color: Colors.black),
              label: const Text('Assign Mechanic', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _chipInactive,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_rounded, color: AppColors.green.withValues(alpha: 0.95), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.mechanic ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(
                          job.status.replaceAll('-', ' '),
                          style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.85), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: EdgeInsets.zero),
                    child: const Text('Reassign', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAssignSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return DraggableScrollableSheet(
              initialChildSize: 0.72,
              minChildSize: 0.4,
              maxChildSize: 0.92,
              builder: (_, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: _headerBg,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(top: BorderSide(color: AppColors.border2)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Assign Mechanic', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_assignJob?.id} · ${_assignJob?.vehicle}',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                setState(() => _assignJob = null);
                              },
                              icon: Icon(Icons.close_rounded, color: AppColors.textMuted.withValues(alpha: 0.9)),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border2),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _kMechanics.length,
                          itemBuilder: (_, i) {
                            final m = _kMechanics[i];
                            final sel = _selectedMechanicId == m.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: _chipInactive,
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  onTap: () {
                                    setModal(() => _selectedMechanicId = m.id);
                                    setState(() => _selectedMechanicId = m.id);
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: sel ? AppColors.primary : AppColors.border2,
                                        width: sel ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withValues(alpha: sel ? 0.30 : 0.20),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(m.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                                  Text(m.id, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                                ],
                                              ),
                                            ),
                                            _mechStatusDot(m.status),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded, size: 16, color: AppColors.primary),
                                            const SizedBox(width: 4),
                                            Text('${m.rating}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                '${m.activeJobs} active · ${m.completed} completed',
                                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.paddingOf(ctx).bottom),
                        child: FilledButton(
                          onPressed: _selectedMechanicId == null
                              ? null
                              : () {
                                  Navigator.pop(ctx);
                                  setState(() {
                                    _assignJob = null;
                                    _selectedMechanicId = null;
                                  });
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.30),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Confirm Assignment', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showInvoiceSheet(BuildContext context, _PendingJob job) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InvoiceReviewSheet(
        job: job,
        onClose: () => Navigator.pop(ctx),
        onApprove: () => Navigator.pop(ctx),
      ),
    );
  }
}

class _InvoiceReviewSheet extends StatefulWidget {
  const _InvoiceReviewSheet({required this.job, required this.onClose, required this.onApprove});

  final _PendingJob job;
  final VoidCallback onClose;
  final VoidCallback onApprove;

  @override
  State<_InvoiceReviewSheet> createState() => _InvoiceReviewSheetState();
}

class _InvoiceReviewSheetState extends State<_InvoiceReviewSheet> {
  late final TextEditingController _callOut;
  late final TextEditingController _labourHours;
  late List<TextEditingController> _partCosts;
  late List<TextEditingController> _partNames;

  static const Color _sheetBg = Color(0xFF0F0F0F);
  static const Color _fieldBg = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    final inv = widget.job.invoice;
    _callOut = TextEditingController(text: inv.callOut.toString());
    _labourHours = TextEditingController(text: inv.labourHours.toString());
    _partNames = inv.parts.map((p) => TextEditingController(text: p.$1)).toList();
    _partCosts = inv.parts.map((p) => TextEditingController(text: p.$2.toString())).toList();
  }

  @override
  void dispose() {
    _callOut.dispose();
    _labourHours.dispose();
    for (final c in _partNames) {
      c.dispose();
    }
    for (final c in _partCosts) {
      c.dispose();
    }
    super.dispose();
  }

  double get _labourRate => widget.job.invoice.hourlyRate.toDouble();

  double get _total {
    final co = double.tryParse(_callOut.text) ?? 0;
    final lh = double.tryParse(_labourHours.text) ?? 0;
    var parts = 0.0;
    for (var i = 0; i < _partCosts.length; i++) {
      parts += double.tryParse(_partCosts[i].text) ?? 0;
    }
    return co + lh * _labourRate + parts;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
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
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Review Invoice', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.job.id} · ${widget.job.vehicle}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: widget.onClose, icon: Icon(Icons.close_rounded, color: AppColors.textMuted.withValues(alpha: 0.9))),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border2),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8 + bottom),
                  children: [
                    _detailsBlock(),
                    const SizedBox(height: 16),
                    _invoiceEditor(),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF60A5FA).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.30)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.help_outline_rounded, color: const Color(0xFF60A5FA).withValues(alpha: 0.95), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Company Review',
                                  style: TextStyle(color: const Color(0xFF60A5FA).withValues(alpha: 0.95), fontSize: 12, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Review and approve this invoice to finalize the job. The amount will be charged to the fleet operator.',
                                  style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.9), fontSize: 11, height: 1.35),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottom),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: widget.onApprove,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('✓ Approve & Complete Job', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: widget.onClose,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: AppColors.border2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
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

  Widget _detailsBlock() {
    final j = widget.job;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'JOB DETAILS',
            style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          _kv('Issue', j.issue),
          _kv('Location', j.location),
          _kv('Mechanic', j.mechanic),
          _kv('Fleet Operator', j.fleet),
          _kv('Completed', j.completedAt),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(k, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ),
          Expanded(child: Text(v, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _invoiceEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'JOB INVOICE',
                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('CALL OUT CHARGE', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _callOut,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _fieldDec(),
          ),
          const SizedBox(height: 12),
          const Text('LABOUR TIME (HOURS)', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _labourHours,
                  onChanged: (_) => setState(() {}),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _fieldDec(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: _sheetBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border2),
                ),
                child: Text('@ £${_labourRate.toInt()}/hr', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Labour total: £${((double.tryParse(_labourHours.text) ?? 0) * _labourRate).toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ),
          const SizedBox(height: 12),
          const Text('PARTS USED', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (var i = 0; i < _partNames.length; i++) ...[
            TextField(
              controller: _partNames[i],
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: _fieldDec(hint: 'Part name'),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _partCosts[i],
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: _fieldDec(hint: '0.00', prefix: '£ '),
            ),
            const SizedBox(height: 10),
          ],
          const Divider(color: AppColors.border2),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Invoice', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
              Text('£${_total.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDec({String? hint, String? prefix}) {
    return InputDecoration(
      filled: true,
      fillColor: _sheetBg,
      hintText: hint,
      prefixText: prefix,
      hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.6)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border2)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.55)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

// ─── Team Management (`CompanyTeam` / check.tsx) ─────────────────────────────

class CompanyTeamManagementView extends StatefulWidget {
  const CompanyTeamManagementView({super.key});

  @override
  State<CompanyTeamManagementView> createState() => _CompanyTeamManagementViewState();
}

class _CompanyTeamManagementViewState extends State<CompanyTeamManagementView> {
  static const Color _headerBg = Color(0xFF0F0F0F);

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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Management',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                      ),
                      SizedBox(height: 4),
                      Text('Manage your mechanics', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showInviteSheet(context),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18, color: Colors.black),
                  label: const Text('Invite', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _kMechanics.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _mechanicCard(_kMechanics[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mechanicCard(_TeamMech m) {
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(m.id, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                  ],
                ),
              ),
              Row(
                children: [
                  _mechStatusDot(m.status),
                  const SizedBox(width: 6),
                  Text(
                    m.status,
                    style: TextStyle(
                      color: m.status == 'active'
                          ? AppColors.green
                          : m.status == 'busy'
                              ? AppColors.orange
                              : AppColors.textHint,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statCell('${m.rating}', 'Rating', AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(child: _statCell('${m.activeJobs}', 'Active', AppColors.orange)),
              const SizedBox(width: 10),
              Expanded(child: _statCell('${m.completed}', 'Done', AppColors.green)),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showMechanicDetail(context, m),
            icon: Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textMuted.withValues(alpha: 0.9)),
            label: Text('More', style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontWeight: FontWeight.w800, fontSize: 12)),
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              side: const BorderSide(color: AppColors.border2),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCell(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border2),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottom = MediaQuery.paddingOf(ctx).bottom;
        return Container(
          padding: EdgeInsets.only(bottom: bottom),
          decoration: const BoxDecoration(
            color: _headerBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: AppColors.border2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Invite Mechanic', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    ),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close_rounded, color: AppColors.textMuted.withValues(alpha: 0.9))),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border2),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Email Address', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        hintText: 'mechanic@example.com',
                        hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.6)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Full Name', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        hintText: 'John Smith',
                        hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.6)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Send Invitation', style: TextStyle(fontWeight: FontWeight.w900)),
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

  void _showMechanicDetail(BuildContext context, _TeamMech m) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: _headerBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: AppColors.border2)),
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.paddingOf(ctx).bottom),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(99)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.20), shape: BoxShape.circle),
                      child: Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                          Text(m.id, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _dotForStatus(m.status),
                              const SizedBox(width: 6),
                              Text(
                                m.status,
                                style: TextStyle(
                                  color: m.status == 'active'
                                      ? AppColors.green
                                      : m.status == 'busy'
                                          ? AppColors.orange
                                          : AppColors.textHint,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'PERFORMANCE',
                  style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _bigStat('${m.rating}', 'RATING', AppColors.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: _bigStat('${m.activeJobs}', 'ACTIVE', AppColors.orange)),
                    const SizedBox(width: 10),
                    Expanded(child: _bigStat('${m.completed}', 'DONE', AppColors.green)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'CONTACT',
                  style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _detailRow('Email', m.email),
                      _detailRow('Phone', m.phone),
                      _detailRow('Joined', m.joinedDate),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SPECIALTIES',
                  style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: m.specialties
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
                          ),
                          child: Text(s, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone_outlined, size: 18, color: Colors.black),
                        label: const Text('CALL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.white.withValues(alpha: 0.9)),
                        label: const Text('MESSAGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.border2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: BorderSide(color: AppColors.red.withValues(alpha: 0.30)),
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: AppColors.red.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Remove from Team', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dotForStatus(String status) {
    Color c;
    switch (status) {
      case 'active':
        c = AppColors.green;
        break;
      case 'busy':
        c = AppColors.orange;
        break;
      default:
        c = AppColors.textHint;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        boxShadow: status == 'active' ? [BoxShadow(color: AppColors.green.withValues(alpha: 0.45), blurRadius: 6)] : null,
      ),
    );
  }

  Widget _bigStat(String v, String l, Color c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(v, style: TextStyle(color: c, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(l, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _detailRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          Flexible(child: Text(v, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

// ─── Company Profile (`CompanyProfile` / check.tsx) ──────────────────────────

class CompanyProfileFullView extends StatelessWidget {
  const CompanyProfileFullView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<CompanyViewModel>();
    final activeOnline = _kMechanics.where((m) => m.status == 'active').length;
    final activeJobSum = _kMechanics.fold<int>(0, (a, m) => a + m.activeJobs);

    return ColoredBox(
      color: const Color(0xFF080808),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMPANY',
                  style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.4),
                ),
                SizedBox(height: 4),
                Text('Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.30), width: 2),
                      ),
                      child: Icon(Icons.business_center_rounded, color: AppColors.primary, size: 40),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF080808), width: 2),
                        ),
                        alignment: Alignment.center,
                        child: const Text('✓', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Swift Mechanics Ltd',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(5, (i) => Icon(Icons.star_rounded, size: 16, color: AppColors.primary)),
                    const SizedBox(width: 6),
                    const Text('4.8', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _profileStatTile('156', 'Total Jobs')),
                const SizedBox(width: 8),
                Expanded(child: _profileStatTile('4.8', 'Avg Rating')),
                const SizedBox(width: 8),
                Expanded(child: _profileStatTile('8 min', 'Response')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FilledButton.icon(
              onPressed: () => vm.setScreen('company-edit-profile'),
              icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.black),
              label: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _profileSection(
              title: 'COMPANY DETAILS',
              child: Column(
                children: [
                  _profileKv('Company Name', 'Swift Mechanics Ltd', strong: true),
                  _profileKv('Registration', '12345678', strong: true),
                  _profileKv('VAT Number', 'Not registered', mutedValue: true),
                  const Divider(height: 20, color: Color(0xFF1E1E1E)),
                  _profileKv('Base Location', 'Birmingham, UK', strong: true),
                  _profileKv('Service Radius', '50 miles', strong: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _profileSection(
              title: 'TEAM OVERVIEW',
              child: Column(
                children: [
                  _profileKv('Total Mechanics', '${_kMechanics.length}', strong: true),
                  _profileKv('Online Now', '$activeOnline', valueColor: AppColors.green),
                  _profileKv('Active Jobs', '$activeJobSum', valueColor: AppColors.orange),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _profileSection(
              title: 'BANK & BILLING',
              child: Column(
                children: [
                  _profileKv('Bank', 'Barclays Business', strong: true),
                  _profileKv('Account', '•••• •••• 9876', strong: true),
                  _profileKv('Sort Code', '20-45-99', strong: true),
                  const Divider(height: 20, color: Color(0xFF1E1E1E)),
                  _profileKv('Billing Address', '45 Industrial Park, Birmingham B12 8QT', strong: true, multiline: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _profileNavTile(
              icon: Icons.payments_outlined,
              title: 'Earnings & Invoices',
              subtitle: 'View company revenue & job history',
              onTap: () => vm.setScreen('company-earnings'),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _profileNavTile(
              icon: Icons.groups_outlined,
              title: 'Manage Team',
              subtitle: 'View & invite mechanics (${_kMechanics.length} total)',
              onTap: () => vm.setScreen('company-team'),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _profileNavTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'Contact TruckFix support team',
              onTap: () => showCompanyHelpSupportSheet(context),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthViewModel>().logout();
                if (context.mounted) context.go(AppRoutes.login);
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.red, size: 18),
              label: const Text('Log Out', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600, fontSize: 12)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.red.withValues(alpha: 0.20)),
                backgroundColor: AppColors.red.withValues(alpha: 0.05),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'TruckFix v2.4.1 · Member since Jan 2026',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.7), fontSize: 10),
          ),
        ],
      ),
    );
  }

  static Widget _profileStatTile(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  static Widget _profileSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Text(
              title,
              style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  static Widget _profileKv(String k, String v, {bool strong = false, bool mutedValue = false, Color? valueColor, bool multiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: multiline ? 2 : 1,
            child: Text(k, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
          Expanded(
            flex: multiline ? 3 : 1,
            child: Text(
              v,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? (mutedValue ? AppColors.textMuted : (strong ? Colors.white : AppColors.textSecondary)),
                fontSize: 12,
                fontWeight: strong ? FontWeight.w600 : FontWeight.w500,
                height: multiline ? 1.35 : 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _profileNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF0F0F0F),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textHint.withValues(alpha: 0.8), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Earnings & Invoices (`CompanyEarnings` / check.tsx) ───────────────────

class _CoEarningJob {
  const _CoEarningJob({
    required this.id,
    required this.truck,
    required this.issue,
    required this.mechanic,
    required this.date,
    required this.gross,
    required this.net,
    required this.rating,
    required this.hours,
  });

  final String id;
  final String truck;
  final String issue;
  final String mechanic;
  final String date;
  final int gross;
  final int net;
  final int rating;
  final String hours;
}

class _CoMonthlyBar {
  const _CoMonthlyBar({required this.month, required this.net, this.current = false});

  final String month;
  final int net;
  final bool current;
}

const List<_CoEarningJob> _kCoCompletedJobs = [
  _CoEarningJob(id: 'TF-8810', truck: 'Rigid 8T · GP 221-560', issue: 'Fuel system fault', mechanic: 'Jake Wilson', date: '7 Mar 2026', gross: 185, net: 163, rating: 5, hours: '1h 45m'),
  _CoEarningJob(id: 'TF-8797', truck: 'Flatbed · WC 334-112', issue: 'Tyre replacement x2', mechanic: 'Jake Wilson', date: '5 Mar 2026', gross: 140, net: 123, rating: 5, hours: '55m'),
  _CoEarningJob(id: 'TF-8782', truck: 'Tautliner · CA 100-221', issue: 'Air brake adjustment', mechanic: 'Dan McCarthy', date: '3 Mar 2026', gross: 220, net: 194, rating: 4, hours: '2h 10m'),
  _CoEarningJob(id: 'TF-8771', truck: 'Tanker · KZN 44-310', issue: 'Coolant system flush', mechanic: 'Sam Hughes', date: '28 Feb 2026', gross: 165, net: 145, rating: 5, hours: '1h 20m'),
  _CoEarningJob(id: 'TF-8760', truck: 'Rigid 18T · WC 887-002', issue: 'Engine diagnostics', mechanic: 'Jake Wilson', date: '25 Feb 2026', gross: 95, net: 84, rating: 4, hours: '40m'),
  _CoEarningJob(id: 'TF-8744', truck: 'Flatbed · GP 551-889', issue: 'Suspension repair', mechanic: 'Dan McCarthy', date: '21 Feb 2026', gross: 310, net: 273, rating: 5, hours: '3h 05m'),
];

const List<_CoMonthlyBar> _kCoMonthlyBars = [
  _CoMonthlyBar(month: 'Oct', net: 820),
  _CoMonthlyBar(month: 'Nov', net: 1140),
  _CoMonthlyBar(month: 'Dec', net: 960),
  _CoMonthlyBar(month: 'Jan', net: 1380),
  _CoMonthlyBar(month: 'Feb', net: 1050),
  _CoMonthlyBar(month: 'Mar', net: 480, current: true),
];

String _coFormatBarAmount(int net) {
  if (net >= 1000) return '£${(net / 1000).toStringAsFixed(1)}k';
  return '£$net';
}

class CompanyEarningsView extends StatelessWidget {
  const CompanyEarningsView({super.key, required this.onBack});

  final VoidCallback onBack;

  Future<void> _showInvoiceSheet(BuildContext context, _CoEarningJob job) async {
    final fee = job.gross - job.net;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.72,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A0A0A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF1A1A1A))),
          ),
          child: Column(
            children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('INVOICE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                        const SizedBox(height: 2),
                        Text('INV-${job.id}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      side: const BorderSide(color: Color(0xFF2A2A2A)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1A1A1A)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1A1A1A)),
                    ),
                    child: Column(
                      children: [
                        _invoiceRow('Job ID', job.id, mono: true),
                        _invoiceRow('Date', job.date),
                        _invoiceRow('Vehicle', job.truck),
                        _invoiceRow('Issue', job.issue),
                        _invoiceRow('Mechanic', job.mechanic),
                        _invoiceRow('Duration', job.hours),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1A1A1A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COST BREAKDOWN',
                          style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 10),
                        _invoiceRow('Gross Amount', '£${job.gross}'),
                        _invoiceRow('Platform Fee (12%)', '-£$fee', valueMuted: true),
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Divider(height: 1, color: Color(0xFF2A2A2A)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'NET PAYOUT',
                                style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                              ),
                              Text('£${job.net}', style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w900)),
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
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1A1A1A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RATING',
                          style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: i < job.rating ? AppColors.primary : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final text = StringBuffer()
                            ..writeln('TruckFix Invoice INV-${job.id}')
                            ..writeln('Job: ${job.id} · ${job.date}')
                            ..writeln('Vehicle: ${job.truck}')
                            ..writeln('Gross £${job.gross} · Fee £$fee · Net £${job.net}');
                          await Clipboard.setData(ClipboardData(text: text.toString()));
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Invoice summary copied to clipboard')));
                          }
                        },
                        icon: const Icon(Icons.download_rounded, size: 18, color: Colors.black),
                        label: const Text('DOWNLOAD INVOICE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Close', style: TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.w600)),
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

  static Widget _invoiceRow(String k, String v, {bool mono = false, bool valueMuted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueMuted ? const Color(0xFF9CA3AF) : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marchGross = _kCoCompletedJobs.where((j) => j.date.contains('Mar')).fold<int>(0, (s, j) => s + j.gross);
    final marchNet = _kCoCompletedJobs.where((j) => j.date.contains('Mar')).fold<int>(0, (s, j) => s + j.net);
    final allTimeNet = _kCoCompletedJobs.fold<int>(0, (s, j) => s + j.net);
    final maxBar = _kCoMonthlyBars.map((b) => b.net).reduce(math.max);

    return ColoredBox(
      color: const Color(0xFF080808),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Material(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: Icon(Icons.chevron_left_rounded, color: AppColors.textMuted, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COMPANY',
                        style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.4),
                      ),
                      SizedBox(height: 2),
                      Text('Earnings & Invoices', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1A1A1A)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  children: [
                    Expanded(child: _summaryMini('£$marchGross', 'MAR GROSS', 'Before platform fee')),
                    const SizedBox(width: 8),
                    Expanded(child: _summaryMini('£$marchNet', 'MAR NET', 'After 12% fee')),
                    const SizedBox(width: 8),
                    Expanded(child: _summaryMini('£$allTimeNet', 'ALL-TIME', 'Net since Mar 2026')),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1A1A1A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'MONTHLY NET INCOME',
                            style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                          ),
                          Text('Last 6 months', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 96,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final bar in _kCoMonthlyBars) ...[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        _coFormatBarAmount(bar.net),
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                          color: bar.current ? AppColors.primary : const Color(0xFF374151),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        height: 56,
                                        width: double.infinity,
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: FractionallySizedBox(
                                            widthFactor: 1,
                                            heightFactor: math.max(100 * bar.net / maxBar, 4) / 100,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: bar.current ? AppColors.primary : const Color(0xFF222222),
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        bar.month,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: bar.current ? AppColors.primary : AppColors.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '12% platform fee already deducted from net figures',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: const Color(0xFF374151), fontSize: 9),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'COMPLETED JOBS',
                      style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                    Text('${_kCoCompletedJobs.length} jobs', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 10),
                ..._kCoCompletedJobs.map((job) => _jobCard(context, job)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _summaryMini(String value, String label, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.3),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF374151), fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _jobCard(BuildContext context, _CoEarningJob job) {
    final fee = job.gross - job.net;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A1A1A)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                            Text(job.id, style: TextStyle(color: AppColors.textHint, fontSize: 10, fontFamily: 'monospace')),
                            Text(' · ', style: TextStyle(color: const Color(0xFF374151), fontSize: 10)),
                            Text(job.date, style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(job.truck, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(job.issue, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('£${job.net}', style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w900)),
                      Text('net earned', style: TextStyle(color: AppColors.textHint, fontSize: 9)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => Icon(Icons.star_rounded, size: 12, color: i < job.rating ? AppColors.primary : const Color(0xFF374151)),
                    ),
                  ),
                  Text(' · ', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                  Expanded(
                    child: Text(job.mechanic, style: TextStyle(color: AppColors.textMuted, fontSize: 10), overflow: TextOverflow.ellipsis),
                  ),
                  Text(' · ', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                  Icon(Icons.schedule_rounded, size: 12, color: AppColors.textHint),
                  const SizedBox(width: 2),
                  Text(job.hours, style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFF1A1A1A)),
              const SizedBox(height: 10),
              Material(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => _showInvoiceSheet(context, job),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Column(
                      children: [
                        _feeRow('Gross', '£${job.gross}'),
                        _feeRow('Fee (12%)', '-£$fee', muted: true),
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Divider(height: 1, color: Color(0xFF2A2A2A)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Net', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
                              Text('£${job.net}', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Divider(height: 1, color: Color(0xFF1E1E1E)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.description_outlined, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text('View Invoice', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
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
    );
  }

  static Widget _feeRow(String k, String v, {bool muted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(color: AppColors.textHint, fontSize: 10)),
          Text(v, style: TextStyle(color: muted ? const Color(0xFF9CA3AF) : Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Help & Support sheet (`HelpSupportSheet` / check.tsx) ─────────────────

enum CompanyHelpSupportRole { company, mechanicEmployee }

Future<void> showCompanyHelpSupportSheet(BuildContext context, {CompanyHelpSupportRole role = CompanyHelpSupportRole.company}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CompanyHelpSupportSheet(role: role),
  );
}

class _CompanyHelpSupportSheet extends StatefulWidget {
  const _CompanyHelpSupportSheet({required this.role});

  final CompanyHelpSupportRole role;

  @override
  State<_CompanyHelpSupportSheet> createState() => _CompanyHelpSupportSheetState();
}

class _CompanyHelpSupportSheetState extends State<_CompanyHelpSupportSheet> {
  String? _category;
  final _messageCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  String get _senderLine {
    switch (widget.role) {
      case CompanyHelpSupportRole.company:
        return 'Sent from: admin@swiftmechanics.co.uk · Company';
      case CompanyHelpSupportRole.mechanicEmployee:
        return 'Sent from: john.smith@swiftmechanics.co.uk · Mechanic Employee';
    }
  }

  static const List<({String id, String label, IconData icon})> _categories = [
    (id: 'technical', label: 'Technical Issue', icon: Icons.build_outlined),
    (id: 'payment', label: 'Payment / Billing', icon: Icons.attach_money_rounded),
    (id: 'account', label: 'Account & Profile', icon: Icons.person_outline_rounded),
    (id: 'job', label: 'Job / Booking', icon: Icons.work_outline_rounded),
    (id: 'other', label: 'Other', icon: Icons.help_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    if (_sent) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E0E0E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
          ),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(999))),
                const SizedBox(height: 20),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                  ),
                  child: Icon(Icons.check_circle_rounded, color: AppColors.green, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('Message Sent!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(
                  'Our support team will respond within 24 hours via your registered email address.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sheetH = MediaQuery.of(context).size.height * 0.88;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: sheetH,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E0E0E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
          ),
          child: Column(
            children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(999)))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Help & Support', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                        SizedBox(height: 2),
                        Text('We usually reply within 24 hours', style: TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    icon: Icon(Icons.close_rounded, color: AppColors.textHint, size: 20),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1A1A1A)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "WHAT'S THIS ABOUT?",
                      style: TextStyle(color: const Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.4,
                      children: _categories.map((c) {
                        final sel = _category == c.id;
                        return Material(
                          color: sel ? AppColors.primary.withValues(alpha: 0.08) : const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => setState(() => _category = c.id),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: sel ? AppColors.primary.withValues(alpha: 0.5) : const Color(0xFF1E1E1E)),
                              ),
                              child: Row(
                                children: [
                                  Icon(c.icon, size: 18, color: sel ? AppColors.primary : AppColors.textHint),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      c.label,
                                      style: TextStyle(
                                        color: sel ? AppColors.primary : const Color(0xFF9CA3AF),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'YOUR MESSAGE',
                      style: TextStyle(color: const Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _messageCtrl,
                      onChanged: (_) => setState(() {}),
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                      decoration: InputDecoration(
                        hintText: 'Describe your issue or question in as much detail as possible...',
                        hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.8), fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF111111),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_senderLine, style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _canSend
                          ? () {
                              setState(() => _sent = true);
                            }
                          : null,
                      icon: Icon(Icons.send_rounded, size: 18, color: _canSend ? Colors.black : Colors.black.withValues(alpha: 0.4)),
                      label: Text(
                        'SEND MESSAGE',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.0,
                          color: _canSend ? Colors.black : Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  bool get _canSend => _category != null && _messageCtrl.text.trim().isNotEmpty;
}
