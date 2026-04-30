import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../routes/app_routes.dart';
import '../../analytics/widgets/stat_card.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/company_viewmodel.dart';

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
    Widget tab(String id, IconData icon, String label) {
      final on = active == id;
      return Expanded(
        child: InkWell(
          onTap: () => vm.setScreen(id),
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
            tab('company-dashboard', Icons.dashboard_outlined, 'Home'),
            tab('company-job-feed', Icons.search, 'Feed'),
            tab('company-jobs', Icons.work_outline, 'Jobs'),
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
        return _coFeed();
      case 'company-jobs':
        return _coJobs();
      case 'company-team':
        return _coTeam(context);
      case 'company-earnings':
        return _coEarnings(() => vm.setScreen('company-profile'));
      case 'company-profile':
        return _coProfile(context, vm);
      case 'company-edit-profile':
        return _coEdit(() => vm.setScreen('company-profile'));
      default:
        return _coDashboard(context);
    }
  }

  Widget _coDashboard(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Company dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: StatCard(label: 'Team jobs', value: '8', icon: Icons.work_outline)),
            SizedBox(width: 12),
            Expanded(child: StatCard(label: 'Quotes', value: '12', icon: Icons.request_quote_outlined)),
          ],
        ),
        const SizedBox(height: 16),
        ListTile(
          tileColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Review pending jobs', style: TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.read<CompanyViewModel>().setScreen('company-jobs'),
        ),
      ],
    );
  }

  Widget _coFeed() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text('Job feed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        SizedBox(height: 12),
        ListTile(
          title: Text('TF-8890 · Cooling fault', style: TextStyle(color: Colors.white)),
          subtitle: Text('Open', style: TextStyle(color: AppColors.textMuted)),
        ),
      ],
    );
  }

  Widget _coJobs() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text('My jobs', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
      ],
    );
  }

  Widget _coTeam(BuildContext context) {
    final team = context.read<JobRepository>().companyTeam();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Team', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
        const SizedBox(height: 12),
        ...team.map(
          (m) => ListTile(
            tileColor: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(m.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            subtitle: Text(m.role, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _coEarnings(VoidCallback back) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(onPressed: back, icon: const Icon(Icons.arrow_back_ios_new)),
            const Text('Earnings', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 12),
        const StatCard(label: 'Net revenue', value: '£5,420', icon: Icons.trending_up),
      ],
    );
  }

  Widget _coProfile(BuildContext context, CompanyViewModel vm) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const ListTile(
          title: Text('Swift Mechanics Ltd', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          subtitle: Text('Company admin', style: TextStyle(color: AppColors.textMuted)),
        ),
        ListTile(
          leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
          title: const Text('Edit profile', style: TextStyle(color: Colors.white)),
          onTap: () => vm.setScreen('company-edit-profile'),
        ),
        ListTile(
          leading: const Icon(Icons.payments_outlined, color: AppColors.primary),
          title: const Text('Earnings', style: TextStyle(color: Colors.white)),
          onTap: () => vm.setScreen('company-earnings'),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () async {
            await context.read<AuthViewModel>().logout();
            if (context.mounted) context.go(AppRoutes.login);
          },
          icon: const Icon(Icons.logout, color: AppColors.red),
          label: const Text('Log out', style: TextStyle(color: AppColors.red)),
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
}
