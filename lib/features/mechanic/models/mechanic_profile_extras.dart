/// Fleet / operator thread shown on mechanic **Messages** list (UI + local demo).
class MechanicMessageThread {
  const MechanicMessageThread({
    required this.id,
    required this.title,
    required this.subtitle,
    this.photoUrl,
    required this.preview,
    required this.timeLabel,
    this.phone,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? photoUrl;
  final String preview;
  final String timeLabel;
  final String? phone;
}

/// Team member under **Employees** (stored locally until API exists).
class MechanicEmployeeRow {
  const MechanicEmployeeRow({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
}
