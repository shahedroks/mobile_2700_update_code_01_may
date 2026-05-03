import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/buttons.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key, required this.onNavigate, this.signupFlow = false});

  final void Function(String) onNavigate;
  /// When true, Continue goes to create-account screens; when false, to login with selected role.
  final bool signupFlow;

  @override
  Widget build(BuildContext context) {
    return _RoleSelectBody(onNavigate: onNavigate, signupFlow: signupFlow);
  }
}

class _RoleSelectBody extends StatefulWidget {
  const _RoleSelectBody({required this.onNavigate, required this.signupFlow});

  final void Function(String) onNavigate;
  final bool signupFlow;

  @override
  State<_RoleSelectBody> createState() => _RoleSelectBodyState();
}

class _RoleSelectBodyState extends State<_RoleSelectBody> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => widget.onNavigate('splash'),
                icon: const Icon(Icons.chevron_left, size: 16, color: AppColors.textGray),
                label: const Text('Back', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
              ),
              const SizedBox(height: 24),
              const Text('Who are you?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Select your account type to get started', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 32),
              _RoleCard(
                id: 'fleet',
                icon: Icons.local_shipping,
                title: 'Fleet Operator',
                subtitle: 'Manage vehicles & request breakdown assistance',
                perks: const ['Post breakdown jobs', 'Track repairs live', 'Full service history & invoices'],
                selected: _selected == 'fleet',
                onTap: () => setState(() => _selected = 'fleet'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                id: 'mechanic',
                icon:  Icons.build_outlined,
                title: 'Service Provider',
                subtitle: 'Accept jobs & earn money helping fleets',
                perks: const ['Browse nearby jobs', 'Submit competitive quotes', 'Get paid instantly'],
                selected: _selected == 'mechanic',
                onTap: () => setState(() => _selected = 'mechanic'),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: _selected == null ? 'Continue as ...' : 'Continue as ${_selected == 'fleet' ? 'Fleet Operator' : 'Service Provider'}',
                onPressed: _selected == null
                    ? null
                    : () {
                        if (widget.signupFlow) {
                          widget.onNavigate(_selected == 'fleet' ? 'fleet-register' : 'mechanic-register');
                        } else {
                          widget.onNavigate(
                            _selected == 'fleet' ? '/login?role=fleet' : '/login?role=mechanic',
                          );
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.perks,
    required this.selected,
    required this.onTap,
  });

  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> perks;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.05) : const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: selected ? Colors.black : AppColors.textGray),
                ),
                const Spacer(),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primary : Colors.transparent,
                    border: Border.all(color: selected ? AppColors.primary : AppColors.borderLight, width: 2),
                  ),
                  child: selected ? const Icon(Icons.check, size: 12, color: Colors.black) : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(color: selected ? Colors.white : AppColors.textGray, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(height: 12),
            ...perks.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? AppColors.primary : AppColors.borderLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(p, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
