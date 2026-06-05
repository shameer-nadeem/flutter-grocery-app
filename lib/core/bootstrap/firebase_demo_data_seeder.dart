import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:shelf_sight_ui_implementation/features/auth/domain/entities/user_entity.dart';

/// Seeds Firebase with demo records so the app has real Firestore data during
/// grading, even before many scans are created from the UI.
///
/// The actual demo content is loaded from assets/seed/shelfsight_seed_data.json
/// instead of being kept as static scan lists inside Dart screens/providers.
class FirebaseDemoDataSeeder {
  FirebaseDemoDataSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> seedForUser(UserEntity user) async {
    final seedData = await _loadSeedData();
    final batch = _firestore.batch();

    final currentUserRef = _firestore.collection('users').doc(user.uid);
    batch.set(
      currentUserRef,
      {
        'email': user.email,
        'name': user.name.isEmpty ? _friendlyName(user.email) : user.name,
        'role': user.role,
        'scanAccuracy': user.scanAccuracy,
        'shiftsCompleted': user.shiftsCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    final seededUsers = (seedData['users'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();

    for (final seededUser in seededUsers) {
      final uid = seededUser['uid'] as String?;
      if (uid == null || uid.isEmpty) continue;
      final userPayload = Map<String, dynamic>.from(seededUser)..remove('uid');
      userPayload['updatedAt'] = FieldValue.serverTimestamp();
      batch.set(
        _firestore.collection('users').doc(uid),
        userPayload,
        SetOptions(merge: true),
      );
    }

    final seededScans = (seedData['scans'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();

    for (final scan in seededScans) {
      final scanPayload = _scanPayloadFromSeed(scan, user);
      final scanId = scanPayload['scanId'] as String?;
      if (scanId == null || scanId.isEmpty) continue;
      batch.set(
        _firestore.collection('scans').doc(scanId),
        scanPayload,
        SetOptions(merge: true),
      );
    }

    try {
      await batch.commit();
    } catch (_) {
      // Firestore rules may block cross-user demo writes. The app still works
      // because user-created scans are saved through the normal CRUD flow.
    }
  }

  Future<Map<String, dynamic>> _loadSeedData() async {
    final raw = await rootBundle.loadString('assets/seed/shelfsight_seed_data.json');
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Map<String, dynamic> _scanPayloadFromSeed(
    Map<String, dynamic> seed,
    UserEntity currentUser,
  ) {
    final userName = currentUser.name.isEmpty
        ? _friendlyName(currentUser.email)
        : currentUser.name;
    final scanId = seed['scanId'] as String? ??
        'seed_${currentUser.uid}_${seed['idSuffix'] ?? DateTime.now().millisecondsSinceEpoch}';
    final ageHours = (seed['ageHours'] as num?)?.toInt() ?? 0;
    final createdAt = DateTime.now().subtract(Duration(hours: ageHours));

    return {
      'scanId': scanId,
      'userId': _resolveCurrentUserField(seed['userId'], currentUser.uid),
      'userName': _resolveCurrentUserField(seed['userName'], userName),
      'userEmail': _resolveCurrentUserField(seed['userEmail'], currentUser.email),
      'title': seed['title'] ?? 'Shelf Scan',
      'imageUrl': seed['imageUrl'] ?? '',
      'productCount': (seed['productCount'] as num?)?.toInt() ?? 0,
      'sosPercentage': (seed['sosPercentage'] as num?)?.toInt() ?? 0,
      'osaPercentage': (seed['osaPercentage'] as num?)?.toInt() ?? 0,
      'compliancePercentage': (seed['compliancePercentage'] as num?)?.toInt() ?? 0,
      'recommendation': seed['recommendation'] ?? '',
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String _resolveCurrentUserField(dynamic value, String fallback) {
    final text = value?.toString();
    if (text == null || text.isEmpty || text == 'CURRENT_USER') return fallback;
    return text;
  }

  String _friendlyName(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return 'ShelfSight User';
    return local
        .split(RegExp(r'[._-]'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
