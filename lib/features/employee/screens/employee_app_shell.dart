import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class EmployeeViewModel extends ChangeNotifier {
  String screen = 'employee-jobs';

  void setScreen(String s) {
    screen = s;
    notifyListeners();
  }

  String get tabResolved => screen == 'employee-tracker' ? 'employee-jobs' : screen;
}

class EmployeeAppShell extends StatelessWidget {
  const EmployeeAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmployeeViewModel(),
      child: const _EmpScaffold(),
    );
  }
}

class _EmpScaffold extends StatelessWidget {
  const _EmpScaffold();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeeViewModel>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Expanded(
            child: _EmployeePageContent(),
          ),
          _EmpTabBar(vm: vm),
        ],
      ),
    );
  }
}

class _EmployeePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeeViewModel>();
    if (vm.screen == 'employee-tracker') {
      return _EmployeeTracker(() => vm.setScreen('employee-jobs'));
    }
    if (vm.screen == 'employee-profile') {
      return const _EmployeeProfilePage();
    }
    return _EmployeeJobs(vm);
  }
}

class _EmployeeProfilePage extends StatelessWidget {
  const _EmployeeProfilePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const ListTile(
          title: Text('Mechanic employee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          subtitle: Text('swiftmechanics.co.uk', style: TextStyle(color: AppColors.textMuted)),
        ),
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
}

class _EmpTabBar extends StatelessWidget {
  const _EmpTabBar({required this.vm});

  final EmployeeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final a = vm.tabResolved;
    Widget t(String id, IconData i, String l) {
      final on = a == id;
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
                  child: Icon(i, size: 18, color: on ? Colors.black : AppColors.textMuted),
                ),
                Text(l, style: TextStyle(fontSize: 8, color: on ? AppColors.primary : AppColors.textHint)),
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
            t('employee-jobs', Icons.work_outline, 'My Jobs'),
            t('employee-profile', Icons.person_outline, 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _EmployeeJobs extends StatelessWidget {
  const _EmployeeJobs(this.vm);

  final EmployeeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('My Jobs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
        const Text('Assigned by company', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 16),
        ListTile(
          tileColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Scania R450 · Brake fault', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          subtitle: const Text('Birmingham Depot · 2.3 mi', style: TextStyle(color: AppColors.textMuted)),
          onTap: () => vm.setScreen('employee-tracker'),
        ),
      ],
    );
  }
}

class _EmployeeTracker extends StatelessWidget {
  const _EmployeeTracker(this.onBack);

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new)),
            const Text('Job tracker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 12),
        const Text('En route to driver · ETA 15 min', style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
