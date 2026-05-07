import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../widgets/app_input.dart';
import '../../../widgets/buttons.dart';

class MechanicRegisterScreen extends StatelessWidget {
  const MechanicRegisterScreen({super.key, required this.onNavigate});

  final void Function(String) onNavigate;

  @override
  Widget build(BuildContext context) {
    return _MechanicRegisterBody(onNavigate: onNavigate);
  }
}

class _MechanicRegisterBody extends StatefulWidget {
  const _MechanicRegisterBody({required this.onNavigate});

  final void Function(String) onNavigate;

  @override
  State<_MechanicRegisterBody> createState() => _MechanicRegisterBodyState();
}

class _MechanicRegisterBodyState extends State<_MechanicRegisterBody> {
  static const int _minPasswordLen = 8;

  bool _showPass = false;
  bool _showConfirm = false;
  double _radius = 30;
  bool _submitting = false;

  final _fullName = TextEditingController();
  final _companyName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _callOutFee = TextEditingController();
  final _hourlyRate = TextEditingController();
  final _emergencySurcharge = TextEditingController();
  final _basePostcode = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _businessType = 'sole_trader'; // sole_trader | company

  @override
  void dispose() {
    _fullName.dispose();
    _companyName.dispose();
    _email.dispose();
    _phone.dispose();
    _callOutFee.dispose();
    _hourlyRate.dispose();
    _emergencySurcharge.dispose();
    _basePostcode.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _passwordsMatch =>
      _password.text.isNotEmpty && _confirm.text.isNotEmpty && _password.text == _confirm.text;

  bool get _passwordStrongEnough => _password.text.trim().length >= _minPasswordLen;

  num? _tryNum(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return null;
    return num.tryParse(v);
  }

  Future<void> _onCreateAccountPressed() async {
    if (_submitting) return;

    final fullName = _fullName.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    final password = _password.text;
    final confirmPassword = _confirm.text;
    final companyName = _companyName.text.trim();
    final basePostcode = _basePostcode.text.trim();

    if (fullName.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }
    if (password.trim().length < _minPasswordLen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters.')),
      );
      return;
    }
    if (password.isEmpty || confirmPassword.isEmpty || password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    final businessType = _businessType == 'company' ? 'COMPANY' : 'SOLE_TRADER';
    final displayName = companyName.isNotEmpty ? companyName : fullName.split(' ').first;

    setState(() => _submitting = true);
    try {
      final auth = context.read<AuthRepository>();
      await auth.registerServiceProvider(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        fullName: fullName,
        displayName: displayName,
        phone: phone,
        businessType: businessType,
        businessName: companyName.isNotEmpty ? companyName : null,
        companyName: companyName.isNotEmpty ? companyName : null,
        basePostcode: basePostcode.isNotEmpty ? basePostcode : null,
        baseLocationText: basePostcode.isNotEmpty ? basePostcode : null,
        callOutFee: _tryNum(_callOutFee.text),
        hourlyRate: _tryNum(_hourlyRate.text),
        emergencySurcharge: _tryNum(_emergencySurcharge.text),
        emergencyRate: _tryNum(_emergencySurcharge.text),
        rateCurrency: 'ZAR',
        coverageRadius: _radius.toInt(),
        skills: const [],
      );
      if (!mounted) return;
      widget.onNavigate('mechanic-terms');
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String get _radiusLabel {
    if (_radius <= 5) return 'Local (≤5 mi)';
    if (_radius <= 15) return 'Town / City';
    if (_radius <= 30) return 'Regional';
    if (_radius <= 50) return 'Wide Area';
    return 'Nationwide';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => widget.onNavigate('role-select-signup'),
                    icon: const Icon(Icons.chevron_left, size: 16, color: AppColors.textGray),
                    label: const Text('Back', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.build_outlined, size: 20, color: Colors.black),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SERVICE PROVIDER', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
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
                padding: const EdgeInsets.all(14),
                children: [
                  const Text(
                    'BUSINESS TYPE',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _businessTypeCard(
                          selected: _businessType == 'sole_trader',
                          icon: Icons.person_outline,
                          title: 'Sole Trader',
                          subtitle: 'Working alone',
                          onTap: () => setState(() => _businessType = 'sole_trader'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _businessTypeCard(
                          selected: _businessType == 'company',
                          icon: Icons.apartment_outlined,
                          title: 'Company',
                          subtitle: 'Multiple mechanics',
                          onTap: () => setState(() => _businessType = 'company'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _businessType == 'company'
                                ? 'You run a workshop with multiple mechanics. Assign jobs, manage your team, and handle company billing from the company dashboard.'
                                : "You work alone and manage all jobs yourself. You'll see all financial information and job details.",
                            style: const TextStyle(color: AppColors.textGray, fontSize: 11, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 96,
                              height: 86,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.borderLight, width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.camera_alt_outlined, size: 22, color: AppColors.textMuted),
                                  SizedBox(height: 6),
                                  Text('PHOTO', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                                ],
                              ),
                            ),
                            Positioned(
                              right: -6,
                              bottom: -6,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, size: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Profile photo (optional)', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('PERSONAL INFO', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Full Name',
                    placeholder: 'Themba Dlamini',
                    controller: _fullName,
                    prefixIcon: const Icon(Icons.person_outline, size: 16, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Company Name (optional)',
                    placeholder: 'e.g. TechMech Workshop',
                    controller: _companyName,
                    prefixIcon: const Icon(Icons.business, size: 16, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Email Address',
                    placeholder: 'themba@fix.co.za',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, size: 16, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Phone Number',
                    placeholder: '+27 82 000 0000',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, size: 16, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 24),
                  const Text('RATES (ZAR)', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Call-out Charge',
                    placeholder: '350',
                    controller: _callOutFee,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.attach_money, size: 16, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Hourly Rate',
                    placeholder: '850',
                    controller: _hourlyRate,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.attach_money, size: 16, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Emergency Surcharge',
                    placeholder: '500',
                    controller: _emergencySurcharge,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.flash_on, size: 16, color: AppColors.error),
                  ),
                  const SizedBox(height: 24),
                  const Text('SERVICE AREA', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Base Postcode',
                    placeholder: 'e.g. 1685',
                    controller: _basePostcode,
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('COVERAGE RADIUS', style: TextStyle(color:AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2),
                      ),
                      Text('${_radius.toInt()} mi · $_radiusLabel', style: const TextStyle(color: AppColors.textGray, fontSize: 10)),
                    ],
                  ),
                  Slider(value: _radius, min: 5, max: 100, divisions: 19, activeColor: AppColors.primary, onChanged: (v) => setState(() => _radius = v)),
                  const SizedBox(height: 24),
                  const Text('SECURITY', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Password',
                    placeholder: 'Create a strong password',
                    obscureText: !_showPass,
                    controller: _password,
                    prefixIcon: const Icon(Icons.lock_outline, size: 16, color: AppColors.textGray),
                    suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, size: 16, color: AppColors.textGray), onPressed: () => setState(() => _showPass = !_showPass)),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Confirm Password',
                    placeholder: 'Re-enter your password',
                    obscureText: !_showConfirm,
                    controller: _confirm,
                    prefixIcon: const Icon(Icons.lock_outline, size: 16, color: AppColors.textGray),
                    suffixIcon: IconButton(icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility, size: 16, color: AppColors.textGray), onPressed: () => setState(() => _showConfirm = !_showConfirm)),
                  ),
                  if (_password.text.isNotEmpty && _confirm.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            (_passwordsMatch && _passwordStrongEnough) ? Icons.check : Icons.close,
                            size: 12,
                            color: (_passwordsMatch && _passwordStrongEnough) ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            !_passwordStrongEnough
                                ? 'Minimum 8 characters required'
                                : _passwordsMatch
                                    ? 'Passwords match'
                                    : "Passwords don't match",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: (_passwordsMatch && _passwordStrongEnough)
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
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
                  PrimaryButton(
                    label: _submitting ? 'Creating…' : 'Create Account →',
                    onPressed: _submitting ? null : _onCreateAccountPressed,
                  ),
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

Widget _businessTypeCard({
  required bool selected,
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: selected ? AppColors.primary : AppColors.textGray),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: selected ? AppColors.primary : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
