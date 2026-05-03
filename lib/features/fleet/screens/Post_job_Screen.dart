import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../categories/job_categories.dart';

/// UK address suggestions (`PostJob` / `check.tsx`).
const List<String> _kUkAddresses = [
  'M1 Motorway, Junction 24 — Leicester Services',
  'M6 Motorway, Corley Services, Warwickshire',
  'M25 Motorway, Thurrock Services, Essex',
  'A1(M) Motorway, Wetherby Services, Yorkshire',
  'M62 Motorway, Birch Services, Manchester',
  'Birmingham City Centre, Broad St, West Midlands',
  'Manchester City Centre, Deansgate, Greater Manchester',
  'M4 Motorway, Reading Services, Berkshire',
  'Leeds City Centre, Wellington St, West Yorkshire',
  'Liverpool Docks, Seaforth, Merseyside',
  'Heathrow Airport, Bath Rd, London',
  'Sheffield Industrial Estate, South Yorkshire',
  'Bristol City Centre, Temple Meads, Bristol',
  'M5 Motorway, Sedgemoor Services, Somerset',
  'Newcastle upon Tyne, Quayside, Tyne and Wear',
];

/// Fleet Post Job — profile gate + full form (`PostJob` / `check.tsx`).
class FleetPostJobScreen extends StatefulWidget {
  const FleetPostJobScreen({
    super.key,
    required this.profileComplete,
    required this.prefilled,
    required this.onSubmit,
    required this.onContinueToJobForm,
  });

  final bool profileComplete;
  final String? prefilled;
  final VoidCallback onSubmit;
  /// From the incomplete-profile gate: show the full Post Job form (emergency / schedule, vehicle, category).
  final VoidCallback onContinueToJobForm;

  @override
  State<FleetPostJobScreen> createState() => _FleetPostJobScreenState();
}

enum _FleetJobMode { emergency, schedulable }

class _FleetPostJobScreenState extends State<FleetPostJobScreen> {
  static const Color _bg = Color(0xFF080808);
  static const Color _fieldFill = Color(0xFF111111);
  static const Color _sectionLabelColor = Color(0xFFB8860B);

  _FleetJobMode _jobMode = _FleetJobMode.emergency;

  final _vehicleReg = TextEditingController(text: 'CA 456-789');
  final _vehicleMake = TextEditingController();
  final _trailerMake = TextEditingController();

  String? _jobCategoryLabel;
  String? _jobCategoryEmoji;
  bool _jobCategoryOpen = false;

  final _locationQuery = TextEditingController();
  final _locationFocus = FocusNode();
  String _selectedLocation = '';
  bool _locationFocused = false;

  final _tyreSize = TextEditingController();
  final _tyreAxle = TextEditingController();
  String _tyreSide = '';

  final _driverName = TextEditingController();
  final _driverNumber = TextEditingController();
  final _notes = TextEditingController();

  final _schedFromDate = TextEditingController();
  final _schedFromTime = TextEditingController();
  final _schedToDate = TextEditingController();
  final _schedToTime = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prefilled != null && widget.prefilled!.isNotEmpty) {
      _vehicleMake.text = widget.prefilled!;
    }
    _locationFocus.addListener(() {
      setState(() => _locationFocused = _locationFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _vehicleReg.dispose();
    _vehicleMake.dispose();
    _trailerMake.dispose();
    _locationQuery.dispose();
    _locationFocus.dispose();
    _tyreSize.dispose();
    _tyreAxle.dispose();
    _driverName.dispose();
    _driverNumber.dispose();
    _notes.dispose();
    _schedFromDate.dispose();
    _schedFromTime.dispose();
    _schedToDate.dispose();
    _schedToTime.dispose();
    super.dispose();
  }

  bool get _isTyreJob => _jobCategoryLabel == 'Flat / Damaged Tyre';

  List<String> get _filteredAddresses {
    final q = _locationQuery.text.trim().toLowerCase();
    if (q.length >= 2) {
      return _kUkAddresses.where((a) => a.toLowerCase().contains(q)).toList();
    }
    return _kUkAddresses.take(5).toList();
  }

  bool get _showLocationDropdown => _locationFocused && _selectedLocation.isEmpty;

  InputDecoration _dec({String? hint, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.85)),
      prefixIcon: prefix,
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.55)),
      ),
    );
  }

  Widget _smallFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: AppColors.textHint.withValues(alpha: 0.95),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: _sectionLabelColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _requiredSectionRow(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.red.withValues(alpha: 0.60), width: 2),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.85), fontSize: 10, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncompleteProfileBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Post Job',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.2),
              ),
              const SizedBox(height: 4),
              Text(
                'Get mechanics responding in minutes',
                style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.9), fontSize: 12),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.primary.withValues(alpha: 0.10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Text(
                      '!',
                      style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.w900, height: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Continue to your job',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                ),
                const SizedBox(height: 10),
                Text(
                  'Company, contact, and billing can be added anytime under Profile. Continue below to describe your job and get mechanics responding.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 12, height: 1.45),
                ),
                const SizedBox(height: 24),
                Container(
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
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.border)),
                        ),
                        child: const Text(
                          'ADD ANYTIME IN PROFILE',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Column(
                          children: [
                            _requiredSectionRow('Company Details', 'Company name, Reg number, VAT number'),
                            const Divider(height: 20, color: AppColors.border),
                            _requiredSectionRow('Contact Person', 'Name, role, phone, email'),
                            const Divider(height: 20, color: AppColors.border),
                            _requiredSectionRow('Billing & Payment', 'Card number, expiry, CCV'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onContinueToJobForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'COMPLETE PROFILE',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Opens the job form on this tab. Use Profile to add or edit fleet & payment details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.8), fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _jobModeCard({
    required _FleetJobMode mode,
    required String emoji,
    required String title,
    required String subtitle,
    required bool emergencyStyle,
  }) {
    final on = _jobMode == mode;
    final borderColor = on
        ? (emergencyStyle ? AppColors.red : AppColors.primary)
        : const Color(0xFF1E1E1E);
    final bg = on
        ? (emergencyStyle ? AppColors.red.withValues(alpha: 0.10) : AppColors.primary.withValues(alpha: 0.10))
        : const Color(0xFF0F0F0F);
    final titleColor = on
        ? (emergencyStyle ? AppColors.red : AppColors.primary)
        : AppColors.textMuted;
    final subColor = on
        ? (emergencyStyle ? AppColors.red.withValues(alpha: 0.70) : AppColors.primary.withValues(alpha: 0.70))
        : AppColors.textHint;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _jobMode = mode),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: on ? 1.5 : 1),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(
                title.toUpperCase(),
                style: TextStyle(color: titleColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.6),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: subColor, fontSize: 9, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, void Function(String) onPick) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: _fieldFill),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      onPick('${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _pickTime(BuildContext context, void Function(String) onPick) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: _fieldFill),
        ),
        child: child!,
      ),
    );
    if (t != null) {
      onPick('${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
    }
  }

  Widget _schedulableWindow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'TRUCK AVAILABLE WINDOW',
            style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Text('FROM', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () => _pickDate(context, (s) => setState(() => _schedFromDate.text = s)),
                  controller: _schedFromDate,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: _dec(hint: 'Date').copyWith(
                    prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () => _pickTime(context, (s) => setState(() => _schedFromTime.text = s)),
                  controller: _schedFromTime,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: _dec(hint: 'Time').copyWith(
                    prefixIcon: const Icon(Icons.schedule_rounded, color: AppColors.textMuted, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'TO',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1),
              ),
              const SizedBox(width: 6),
              Text(
                '(optional)',
                style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.9), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () => _pickDate(context, (s) => setState(() => _schedToDate.text = s)),
                  controller: _schedToDate,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: _dec(hint: 'Date').copyWith(
                    prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () => _pickTime(context, (s) => setState(() => _schedToTime.text = s)),
                  controller: _schedToTime,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: _dec(hint: 'Time').copyWith(
                    prefixIcon: const Icon(Icons.schedule_rounded, color: AppColors.textMuted, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mapStub() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(10),
        child: Text(
          'TruckFix Maps',
          style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.85), fontSize: 10),
        ),
      ),
    );
  }

  Widget _buildJobFormBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Post Job',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.2),
              ),
              const SizedBox(height: 4),
              Text(
                'Fill in details to find a mechanic fast',
                style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.9), fontSize: 12),
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
                _sectionTitle('Job Mode'),
                Row(
                  children: [
                    Expanded(
                      child: _jobModeCard(
                        mode: _FleetJobMode.emergency,
                        emoji: '🚨',
                        title: 'Emergency',
                        subtitle: 'Dispatch now',
                        emergencyStyle: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _jobModeCard(
                        mode: _FleetJobMode.schedulable,
                        emoji: '📅',
                        title: 'Schedulable',
                        subtitle: 'Pick date & time',
                        emergencyStyle: false,
                      ),
                    ),
                  ],
                ),
                if (_jobMode == _FleetJobMode.schedulable) ...[
                  const SizedBox(height: 10),
                  _schedulableWindow(),
                ],
                const SizedBox(height: 20),
                _sectionTitle('Vehicle Details'),
                _smallFieldLabel('Registration'),
                TextField(
                  controller: _vehicleReg,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textCapitalization: TextCapitalization.characters,
                  decoration: _dec(hint: 'e.g. CA 456-789'),
                ),
                const SizedBox(height: 12),
                _smallFieldLabel('Vehicle Make & Model'),
                TextField(
                  controller: _vehicleMake,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _dec(hint: 'e.g. Mercedes Actros 2645, Volvo FH16…'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _smallFieldLabel('Trailer Make & Model')),
                    Text(
                      'Optional',
                      style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.9), fontSize: 10),
                    ),
                  ],
                ),
                TextField(
                  controller: _trailerMake,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _dec(hint: 'e.g. Henred Fruehauf, SA Truck Bodies…'),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Job Category'),
                Material(
                  color: _fieldFill,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => setState(() => _jobCategoryOpen = !_jobCategoryOpen),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _jobCategoryOpen ? AppColors.primary.withValues(alpha: 0.55) : AppColors.border2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _jobCategoryLabel == null
                                  ? 'Select job category…'
                                  : '${_jobCategoryEmoji ?? ''}  $_jobCategoryLabel',
                              style: TextStyle(
                                color: _jobCategoryLabel == null ? AppColors.textHint : Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: _jobCategoryOpen ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.expand_more_rounded, color: AppColors.textMuted, size: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_jobCategoryOpen) ...[
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: _fieldFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < JobCategories.postJobCategories.length; i++)
                          InkWell(
                            onTap: () {
                              final t = JobCategories.postJobCategories[i];
                              setState(() {
                                _jobCategoryLabel = t.$2;
                                _jobCategoryEmoji = t.$1;
                                _jobCategoryOpen = false;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: i == JobCategories.postJobCategories.length - 1
                                  ? null
                                  : const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
                                    ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 28,
                                    child: Text(JobCategories.postJobCategories[i].$1, style: const TextStyle(fontSize: 16)),
                                  ),
                                  Expanded(
                                    child: Text(
                                      JobCategories.postJobCategories[i].$2,
                                      style: TextStyle(
                                        color: _jobCategoryLabel == JobCategories.postJobCategories[i].$2
                                            ? AppColors.primary
                                            : AppColors.textMuted,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (_jobCategoryLabel == JobCategories.postJobCategories[i].$2)
                                    const Icon(Icons.check_rounded, color: AppColors.primary, size: 18),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (_isTyreJob) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '🛞 TYRE DETAILS',
                          style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                        ),
                        const SizedBox(height: 12),
                        _smallFieldLabel('Tyre Size'),
                        TextField(
                          controller: _tyreSize,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _dec(hint: 'e.g. 295/80 R22.5, 315/70 R22.5…'),
                        ),
                        const SizedBox(height: 12),
                        _smallFieldLabel('Side'),
                        Row(
                          children: [
                            Expanded(child: _tyreSideChip('NS', 'Near Side', 'Left / Kerb')),
                            const SizedBox(width: 6),
                            Expanded(child: _tyreSideChip('OS', 'Off Side', 'Right / Road')),
                            const SizedBox(width: 6),
                            Expanded(child: _tyreSideChip('BOTH', 'Both', 'NS & OS')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _smallFieldLabel('Axle Position'),
                        TextField(
                          controller: _tyreAxle,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: _dec(hint: 'e.g. Steer, Drive 1, Drive 2, Tag, Trailer 1…'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Type the axle — e.g. "Drive 1", "Steer", "Trailer 2"',
                          style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.85), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _sectionTitle('Breakdown Location'),
                TextField(
                  controller: _locationQuery,
                  focusNode: _locationFocus,
                  onChanged: (_) {
                    setState(() {
                      if (_selectedLocation.isNotEmpty) _selectedLocation = '';
                    });
                  },
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _dec(hint: 'Type a street, highway or landmark…').copyWith(
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                    suffixIcon: _locationQuery.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded, color: AppColors.textMuted.withValues(alpha: 0.9)),
                            onPressed: () {
                              setState(() {
                                _locationQuery.clear();
                                _selectedLocation = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
                if (_showLocationDropdown) ...[
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: _fieldFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView(
                      shrinkWrap: true,
                      children: _filteredAddresses.isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Text('No results found', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              ),
                            ]
                          : _filteredAddresses
                              .map(
                                (addr) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedLocation = addr;
                                      _locationQuery.clear();
                                      _locationFocus.unfocus();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.place_outlined, size: 16, color: AppColors.textMuted),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(addr, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
                if (_selectedLocation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _selectedLocation,
                    style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 10),
                Material(
                  color: const Color(0xFF0F0F0F),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLocation = 'N1 Highway, km 184 — Current GPS Position, GP';
                        _locationQuery.clear();
                        _locationFocus.unfocus();
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
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
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
                            ),
                            child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Use my current location',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'GPS · 25.8°S, 28.2°E',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_selectedLocation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _mapStub(),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _sectionTitle('Driver Details')),
                    Text(
                      'Optional',
                      style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.9), fontSize: 10),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _driverName,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _dec(hint: 'Driver name').copyWith(
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _driverNumber,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: _dec(hint: '+27 82 000 0000').copyWith(
                          prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textMuted, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _sectionTitle('Photos')),
                    Text(
                      'Optional · up to 5',
                      style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.9), fontSize: 10),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera (demo)')));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                          side: const BorderSide(color: Color(0xFF1E1E1E)),
                          backgroundColor: const Color(0xFF0F0F0F),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.photo_camera_outlined, color: AppColors.primary, size: 18),
                        label: const Text('Camera', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gallery (demo)')));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                          side: const BorderSide(color: Color(0xFF1E1E1E)),
                          backgroundColor: const Color(0xFF0F0F0F),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.image_outlined, color: AppColors.primary, size: 18),
                        label: const Text('Gallery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E1E1E)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, color: AppColors.textHint.withValues(alpha: 0.8), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'No photos added yet',
                        style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.85), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Helps mechanics diagnose before arriving on site',
                  style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.85), fontSize: 10),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Notes'),
                TextField(
                  controller: _notes,
                  maxLines: 4,
                  maxLength: 500,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _dec(
                    hint: 'Describe the problem in detail — symptoms, warning lights, sounds, what happened before breakdown…',
                  ),
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$currentLength / ${maxLength ?? 500}',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.8), fontSize: 10),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment Pre-Auth', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                          Text('£220', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: SizedBox(
                          height: 8,
                          child: LinearProgressIndicator(
                            value: 0.5,
                            backgroundColor: const Color(0xFF1A1A1A),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('£50', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          Text('£450', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.credit_card_rounded, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'VISA •••• 4891 · Held until completion',
                              style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.95), fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: widget.onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _jobMode == _FleetJobMode.emergency ? '🚨' : '📅',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _jobMode == _FleetJobMode.emergency ? 'POST EMERGENCY JOB' : 'SCHEDULE JOB',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _jobMode == _FleetJobMode.emergency
                    ? 'Mechanics will respond within minutes. Your job is now live.'
                    : 'Mechanics will be notified and can quote on your scheduled window.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textHint.withValues(alpha: 0.85), fontSize: 10, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tyreSideChip(String id, String title, String sub) {
    final on = _tyreSide == id;
    return Material(
      color: on ? AppColors.primary.withValues(alpha: 0.10) : _fieldFill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _tyreSide = id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: on ? AppColors.primary : AppColors.border2),
          ),
          child: Column(
            children: [
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: on ? AppColors.primary : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: TextStyle(color: on ? AppColors.primary.withValues(alpha: 0.65) : AppColors.textHint, fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: widget.profileComplete ? _buildJobFormBody(context) : _buildIncompleteProfileBody(),
    );
  }
}
