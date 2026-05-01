class Vehicle {
  const Vehicle({
    required this.id,
    required this.label,
    required this.plate,
    this.type,
    this.categoryBadge,
    this.lastService,
  });

  final String id;
  final String label;
  final String plate;
  final String? type;
  /// Uppercase fleet type pill (e.g. TAUTLINER). Falls back to [type] when null.
  final String? categoryBadge;
  /// Shown on fleet list (e.g. "15 Jan 2025").
  final String? lastService;
}
