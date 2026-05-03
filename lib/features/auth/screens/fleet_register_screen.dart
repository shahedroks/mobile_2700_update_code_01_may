import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_input.dart';
import '../../../widgets/buttons.dart';

class FleetRegisterScreen extends StatelessWidget {
  const FleetRegisterScreen({super.key, required this.onNavigate});

  final void Function(String) onNavigate;

  @override
  Widget build(BuildContext context) {
    return _FleetRegisterBody(onNavigate: onNavigate);
  }
}

class _FleetRegisterBody extends StatefulWidget {
  const _FleetRegisterBody({required this.onNavigate});

  final void Function(String) onNavigate;

  @override
  State<_FleetRegisterBody> createState() => _FleetRegisterBodyState();
}

class _FleetRegisterBodyState extends State<_FleetRegisterBody> {
  bool _showPass = false;
  bool _showConfirm = false;
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _passwordsMatch =>
      _password.text.isNotEmpty && _confirm.text.isNotEmpty && _password.text == _confirm.text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top:10, left: 24, right: 24, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => widget.onNavigate('role-select-signup'),
                    icon: const Icon(Icons.chevron_left, size: 16, color: AppColors.textGray),
                    label: const Text('Back', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.local_shipping, size: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FLEET OPERATOR', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
                          Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  AppInput(label: 'Company Name', placeholder: 'Logistix Transport (Pty) Ltd', prefixIcon: const Icon(Icons.business, size: 16, color: AppColors.textGray)),
                  const SizedBox(height: 16),
                  AppInput(label: 'Full Name', placeholder: 'John Khumalo', prefixIcon: const Icon(Icons.person_outline, size: 16, color: AppColors.textGray)),
                  const SizedBox(height: 16),
                  AppInput(label: 'Email Address', placeholder: 'john@logistix.co.za', keyboardType: TextInputType.emailAddress, prefixIcon: const Icon(Icons.email_outlined, size: 16, color: AppColors.textGray)),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Password',
                    placeholder: 'Create a strong password',
                    obscureText: !_showPass,
                    controller: _password,
                    prefixIcon: const Icon(Icons.lock_outline, size: 16, color: AppColors.textGray),
                    suffixIcon: IconButton(
                      icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, size: 16, color: AppColors.textGray),
                      onPressed: () => setState(() => _showPass = !_showPass),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Confirm Password',
                    placeholder: 'Re-enter your password',
                    obscureText: !_showConfirm,
                    controller: _confirm,
                    prefixIcon: const Icon(Icons.lock_outline, size: 16, color: AppColors.textGray),
                    suffixIcon: IconButton(
                      icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility, size: 16, color: AppColors.textGray),
                      onPressed: () => setState(() => _showConfirm = !_showConfirm),
                    ),
                  ),
                  if (_password.text.isNotEmpty && _confirm.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(_passwordsMatch ? Icons.check : Icons.close, size: 12, color: _passwordsMatch ? AppColors.success : AppColors.error),
                          const SizedBox(width: 4),
                          Text(
                            _passwordsMatch ? 'Passwords match' : "Passwords don't match",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _passwordsMatch ? AppColors.success : AppColors.error),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                children: [
                  PrimaryButton(label: 'Create Account →', onPressed: () => widget.onNavigate('terms')),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already registered? ', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      GestureDetector(
                        onTap: () => widget.onNavigate('login'),
                        child: const Text('Sign in', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
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
  }
}
