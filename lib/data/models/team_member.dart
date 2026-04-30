class TeamMember {
  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.activeJobs = 0,
  });

  final String id;
  final String name;
  final String role;
  final String email;
  final int activeJobs;
}
