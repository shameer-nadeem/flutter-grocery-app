class UserEntity {
  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.scanAccuracy = 95.0,
    this.shiftsCompleted = 0,
  });

  final String uid;
  final String email;
  final String name;
  final String role; // 'user' or 'admin'
  final double scanAccuracy;
  final int shiftsCompleted;

  bool get isAdmin => role == 'admin';
}
