/// Fleet-side job tracking summary.
class FleetJobSummary {
  const FleetJobSummary({
    required this.id,
    required this.truck,
    required this.issue,
    required this.status,
    required this.urgency,
    required this.urgencyColorHex,
    required this.urgencyBgHex,
    required this.statusColorHex,
    required this.statusBgHex,
  });

  final String id;
  final String truck;
  final String issue;
  final String status;
  final String urgency;
  final int urgencyColorHex;
  final int urgencyBgHex;
  final int statusColorHex;
  final int statusBgHex;
}
