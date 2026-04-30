import '../../features/categories/job_taxonomy.dart';

/// Job card in mechanic feed.
class JobOffer {
  const JobOffer({
    required this.id,
    required this.truck,
    required this.issue,
    required this.distanceMi,
    required this.urgency,
    required this.pay,
    required this.posted,
    required this.quotes,
  });

  final String id;
  final String truck;
  final String issue;
  final double distanceMi;
  final JobUrgency urgency;
  final String pay;
  final String posted;
  final int quotes;
}
