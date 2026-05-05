enum UserRole { fleet, mechanic, company, employee }

class Session {
  const Session({
    required this.email,
    required this.role,
    this.displayName,
    this.accessToken,
    this.refreshToken,
  });

  final String email;
  final UserRole role;
  final String? displayName;
  final String? accessToken;
  final String? refreshToken;
}
