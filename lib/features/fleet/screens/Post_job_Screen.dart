import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../categories/job_categories.dart';

/// Fleet Post Job tab — incomplete profile matches reference UI; otherwise shows job form.
class FleetPostJobScreen extends StatefulWidget {
  const FleetPostJobScreen({
    super.key,
    required this.profileComplete,
    required this.prefilled,
    required this.onSubmit,
    required this.onEditProfile,
  });

  final bool profileComplete;
  final String? prefilled;
  final VoidCallback onSubmit;
  final VoidCallback onEditProfile;

  @override
  State<FleetPostJobScreen> createState() => _FleetPostJobScreenState();
}

class _FleetPostJobScreenState extends State<FleetPostJobScreen> {
  late String _issue;

  @override
  void initState() {
    super.initState();
    _issue = JobCategories.postJobIssueHints.first;
  }

  static const Color _bg = Color(0xFF000000);

  Widget _requiredSectionRow(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.red, width: 2),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncompleteProfileBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const Text(
          'Post Job',
          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Get mechanics responding in minutes',
          style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 14, height: 1.35),
        ),
        const SizedBox(height: 32),
        Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Text(
                '!',
                style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w900, height: 1),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Complete your profile first',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Text(
          'Before posting a job you must fill in all required profile details so mechanics and billing can be processed correctly.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 13, height: 1.45),
        ),
        const SizedBox(height: 28),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'REQUIRED SECTIONS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _requiredSectionRow('Company Details', 'Company name, Reg number, VAT number'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
              ),
              _requiredSectionRow('Contact Person', 'Name, role, phone, email'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
              ),
              _requiredSectionRow('Billing & Payment', 'Card number, expiry, CCV'),
              const SizedBox(height: 16),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'COMPLETE PROFILE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.6),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'You will be redirected back here once saved.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.75), fontSize: 11, height: 1.35),
        ),
      ],
    );
  }

  Widget _buildJobFormBody() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Post Job', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Vehicle / reg'.toUpperCase(),
            hintText: widget.prefilled ?? 'e.g. Volvo FH · LD 882 TF',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _issue,
          dropdownColor: AppColors.card2,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: const InputDecoration(labelText: 'ISSUE TYPE'),
          items: JobCategories.postJobIssueHints
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => _issue = v ?? _issue),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'DESCRIPTION',
            hintText: 'Describe symptoms, location, access…',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: widget.onSubmit, child: const Text('Submit job')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: widget.profileComplete ? _buildJobFormBody() : _buildIncompleteProfileBody(),
    );
  }
}
