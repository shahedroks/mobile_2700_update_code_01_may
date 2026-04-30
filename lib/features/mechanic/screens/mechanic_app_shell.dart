import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/job_offer.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/truckfix_map_preview.dart';
import '../../analytics/widgets/stat_card.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../categories/job_taxonomy.dart';
import '../viewmodel/mechanic_viewmodel.dart';

class MechanicAppShell extends StatelessWidget {
  const MechanicAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => MechanicViewModel(ctx.read<JobRepository>()),
      child: const _MechScaffold(),
    );
  }
}

class _MechScaffold extends StatelessWidget {
  const _MechScaffold();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MechanicViewModel>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Expanded(child: _MechBody()),
          _MechBottomNav(vm: vm),
        ],
      ),
    );
  }
}

class _MechBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MechanicViewModel>();
    switch (vm.tab) {
      case 'feed':
        return const _JobFeedPage();
      case 'my-quotes':
        return _MyQuotes(onBack: () => vm.setTab('feed'));
      case 'quote-detail':
        return _QuoteDetailPage(onBack: () => vm.setTab('my-quotes'));
      case 'my-jobs':
        return _MyJobsPage(onTracker: () => vm.setTab('job-tracker'));
      case 'job-tracker':
        return _JobTrackerPage(onBack: () => vm.setTab('my-jobs'));
      case 'earnings':
        return _MechanicEarnings(onBack: () => vm.setTab('profile'));
      case 'edit-profile':
        return _MechanicEditProfile(onDone: () => vm.setTab('profile'));
      case 'payment-methods':
        return _MechPayment(onClose: () => vm.setTab('profile'));
      case 'profile':
        return _MechanicProfile(
          onEarnings: () => vm.setTab('earnings'),
          onEdit: () => vm.setTab('edit-profile'),
          onPayment: () => vm.setTab('payment-methods'),
          onLogout: () async {
            await context.read<AuthViewModel>().logout();
            if (context.mounted) context.go(AppRoutes.login);
          },
        );
      default:
        return const _JobFeedPage();
    }
  }
}

class _MechBottomNav extends StatelessWidget {
  const _MechBottomNav({required this.vm});

  final MechanicViewModel vm;

  @override
  Widget build(BuildContext context) {
    final a = vm.bottomNavResolved;
    Widget item(String id, IconData icon, String label) {
      final on = a == id;
      return Expanded(
        child: InkWell(
          onTap: () => vm.setTab(id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: on ? AppColors.primary : AppColors.textHint),
                ),
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
            item('feed', Icons.work_outline, 'Jobs'),
            item('my-quotes', Icons.list_alt, 'Quotes'),
            item('my-jobs', Icons.bolt, 'My Jobs'),
            item('profile', Icons.person_outline, 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _JobFeedPage extends StatelessWidget {
  const _JobFeedPage();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MechanicViewModel>();
    final jobs = vm.online ? vm.filteredJobs() : <JobOffer>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Job Feed', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('Nearby breakdown jobs', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            if (vm.online)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.payments_outlined, size: 14, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text('£465 today', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: vm.toggleOnline,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: vm.online ? AppColors.green.withValues(alpha: 0.1) : AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: vm.online ? AppColors.green.withValues(alpha: 0.55) : AppColors.border2,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, color: vm.online ? AppColors.green : AppColors.textMuted, size: 14),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.online ? 'ONLINE' : 'OFFLINE',
                        style: TextStyle(
                          color: vm.online ? AppColors.green : AppColors.textMuted,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        vm.online ? 'Receiving nearby breakdown jobs' : 'Tap to go online',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: vm.online,
                  onChanged: (_) => vm.toggleOnline(),
                  activeTrackColor: AppColors.green.withValues(alpha: 0.5),
                  activeThumbColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => _MechanicFeedSheets.radius(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
                foregroundColor: AppColors.primary,
              ),
              child: Text('${vm.radiusMi} mi radius'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _MechanicFeedSheets.postcode(context),
                child: Text(
                  '${vm.city}, ${vm.postcode}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        if (vm.online) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _distChip(vm, 'All', null),
                _distChip(vm, '≤ 5 mi', 5),
                _distChip(vm, '≤ 10 mi', 10),
                _distChip(vm, '≤ ${vm.radiusMi} mi', vm.radiusMi),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (!vm.online)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.offline_bolt, size: 56, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text("You're offline", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                    'Toggle online to receive jobs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          ...jobs.map((j) => _jobCard(context, j)),
      ],
    );
  }

  Widget _distChip(MechanicViewModel vm, String label, int? max) {
    final on = vm.maxDistMi == max;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
        selected: on,
        onSelected: (_) => vm.setMaxDist(max),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(color: on ? AppColors.primary : AppColors.textMuted),
        side: BorderSide(color: on ? AppColors.primary : AppColors.border),
      ),
    );
  }

  Widget _jobCard(BuildContext context, JobOffer j) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => context.read<MechanicViewModel>().setTab('quote-detail'),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(j.id, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'monospace')),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: j.urgency.chipBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: j.urgency.chipBorder),
                      ),
                      child: Text(
                        urgencyLabel(j.urgency),
                        style: TextStyle(color: j.urgency.foreground, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(j.truck, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                Text(j.issue, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${j.distanceMi} mi', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text(j.pay, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
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

class _MechanicFeedSheets {
  static Future<void> radius(BuildContext context) async {
    final vm = context.read<MechanicViewModel>();
    var draft = vm.radiusMi;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Search radius: $draft mi', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  Slider(
                    value: draft.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setSt(() => draft = v.round()),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      vm.setRadius(draft);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> postcode(BuildContext context) async {
    final vm = context.read<MechanicViewModel>();
    final c = TextEditingController(text: vm.postcode);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Postcode'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                vm.applyLocation(c.text);
                Navigator.pop(ctx);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyQuotes extends StatelessWidget {
  const _MyQuotes({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new)),
            const Text('My quotes', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        const ListTile(
          title: Text('TF-8821 · £185', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          subtitle: Text('Pending response', style: TextStyle(color: AppColors.textMuted)),
        ),
      ],
    );
  }
}

class _QuoteDetailPage extends StatelessWidget {
  const _QuoteDetailPage({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new)),
            const Text('Quote detail', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        const TruckFixMapPreview(height: 160),
        const SizedBox(height: 16),
        const Text(
          'Review labour, call-out and parts before submitting.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _MyJobsPage extends StatelessWidget {
  const _MyJobsPage({required this.onTracker});

  final VoidCallback onTracker;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('My jobs', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        const SizedBox(height: 16),
        ListTile(
          tileColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('TF-8822 · Brake fault', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          subtitle: const Text('In progress', style: TextStyle(color: AppColors.green)),
          onTap: onTracker,
        ),
      ],
    );
  }
}

class _JobTrackerPage extends StatelessWidget {
  const _JobTrackerPage({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new)),
            const Text('Job tracker', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        const TruckFixMapPreview(height: 220, showRoute: true),
        const SizedBox(height: 16),
        const Text(
          'Mechanic en route · ETA 12 min',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _MechanicEarnings extends StatelessWidget {
  const _MechanicEarnings({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new)),
            const Text('Earnings', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          ],
        ),
        const SizedBox(height: 16),
        const StatCard(label: 'This week', value: '£1,842', subtitle: 'After platform fee', icon: Icons.trending_up),
        const SizedBox(height: 12),
        const StatCard(label: 'Completed jobs', value: '14', icon: Icons.check_circle_outline),
      ],
    );
  }
}

class _MechanicEditProfile extends StatelessWidget {
  const _MechanicEditProfile({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(onPressed: onDone, icon: const Icon(Icons.close)),
            const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        ElevatedButton(onPressed: onDone, child: const Text('Save')),
      ],
    );
  }
}

class _MechPayment extends StatelessWidget {
  const _MechPayment({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            const Text('Payout methods'),
          ],
        ),
      ],
    );
  }
}

class _MechanicProfile extends StatelessWidget {
  const _MechanicProfile({
    required this.onEarnings,
    required this.onEdit,
    required this.onPayment,
    required this.onLogout,
  });

  final VoidCallback onEarnings;
  final VoidCallback onEdit;
  final VoidCallback onPayment;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: AppAssets.mechanicPortrait,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deon van Wyk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                  Text('Verified mechanic · 4.9★', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 20),
        ListTile(
          tileColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: const Icon(Icons.payments_outlined, color: AppColors.primary),
          title: const Text('Earnings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
          onTap: onEarnings,
        ),
        const SizedBox(height: 8),
        ListTile(
          tileColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: const Icon(Icons.credit_card, color: AppColors.primary),
          title: const Text('Payment methods', style: TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
          onTap: onPayment,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout, color: AppColors.red),
          label: const Text('Log out', style: TextStyle(color: AppColors.red)),
        ),
      ],
    );
  }
}
