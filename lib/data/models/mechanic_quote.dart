class MechanicQuote {
  const MechanicQuote({
    required this.id,
    required this.name,
    required this.rating,
    required this.jobs,
    required this.verified,
    required this.distance,
    required this.eta,
    required this.imageUrl,
    required this.labour,
    required this.callout,
    required this.parts,
    required this.total,
    required this.speciality,
    required this.responded,
  });

  final String id;
  final String name;
  final double rating;
  final int jobs;
  final bool verified;
  final String distance;
  final String eta;
  final String imageUrl;
  final String labour;
  final String callout;
  final String parts;
  final String total;
  final String speciality;
  final String responded;
}
