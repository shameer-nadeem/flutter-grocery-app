import 'package:shelf_sight_ui_implementation/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.role,
    super.scanAccuracy,
    super.shiftsCompleted,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
      scanAccuracy: (map['scanAccuracy'] as num?)?.toDouble() ?? 95.0,
      shiftsCompleted: map['shiftsCompleted'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'scanAccuracy': scanAccuracy,
      'shiftsCompleted': shiftsCompleted,
    };
  }
}
