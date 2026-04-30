class Vehicle {
  const Vehicle({
    required this.id,
    required this.label,
    required this.plate,
    this.type,
  });

  final String id;
  final String label;
  final String plate;
  final String? type;
}
