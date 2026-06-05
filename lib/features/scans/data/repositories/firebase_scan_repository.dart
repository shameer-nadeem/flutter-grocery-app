import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shelf_sight_ui_implementation/features/scans/data/datasources/firebase_scan_remote_data_source.dart';
import 'package:shelf_sight_ui_implementation/features/scans/data/datasources/firebase_storage_uploader.dart';
import 'package:shelf_sight_ui_implementation/features/scans/data/models/scan_result_model.dart';
import 'package:shelf_sight_ui_implementation/features/scans/domain/entities/scan_result_entity.dart';
import 'package:shelf_sight_ui_implementation/features/scans/domain/repositories/scan_repository.dart';

class FirebaseScanRepository implements ScanRepository {
  FirebaseScanRepository({FirebaseScanRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirebaseScanRemoteDataSource();

  final FirebaseScanRemoteDataSource _remoteDataSource;

  FirebaseFirestore get _firestore => _remoteDataSource.firestore;
  FirebaseStorage get _storage => _remoteDataSource.storage;

  @override
  Future<ScanResultEntity> saveScan(ScanResultEntity scan) async {
    final scansCollection = _remoteDataSource.scansCollection;
    final String docId = scan.id.isEmpty ? scansCollection.doc().id : scan.id;
    final userDetails = await _getUserDetails(scan);

    final scanModel = _toModel(
      scan.copyWith(
        id: docId,
        userEmail: userDetails.email,
        userName: userDetails.name,
      ),
    );

    await scansCollection.doc(docId).set({
      ...scanModel.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _updateUserStatsOnCreate(scan.userId, scan.compliance);
    return scanModel;
  }

  @override
  Future<ScanResultEntity> updateScan(ScanResultEntity scan) async {
    if (scan.id.isEmpty) {
      throw Exception('Cannot update a scan without an id.');
    }

    final scanModel = _toModel(scan);
    await _remoteDataSource.scansCollection.doc(scan.id).set(
      {
        ...scanModel.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    return scanModel;
  }

  @override
  Future<List<ScanResultEntity>> getScansForUser(String userId) async {
    try {
      final querySnapshot = await _remoteDataSource.scansCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => ScanResultModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      final querySnapshot = await _remoteDataSource.scansCollection
          .where('userId', isEqualTo: userId)
          .get();
      final results = querySnapshot.docs
          .map((doc) => ScanResultModel.fromMap(doc.data(), doc.id))
          .toList();
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results;
    }
  }

  @override
  Stream<List<ScanResultEntity>> streamScansForUser(String userId) {
    return _remoteDataSource.scansCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final results = snapshot.docs
          .map((doc) => ScanResultModel.fromMap(doc.data(), doc.id))
          .toList();
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results;
    });
  }

  @override
  Future<List<ScanResultEntity>> getAllScans() async {
    try {
      final querySnapshot = await _remoteDataSource.scansCollection
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => ScanResultModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      final querySnapshot = await _remoteDataSource.scansCollection.get();
      final results = querySnapshot.docs
          .map((doc) => ScanResultModel.fromMap(doc.data(), doc.id))
          .toList();
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results;
    }
  }

  @override
  Stream<List<ScanResultEntity>> streamAllScans() {
    return _remoteDataSource.scansCollection.snapshots().map((snapshot) {
      final results = snapshot.docs
          .map((doc) => ScanResultModel.fromMap(doc.data(), doc.id))
          .toList();
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results;
    });
  }

  @override
  Future<String> uploadImage(String localPath) async {
    if (localPath.startsWith('assets/') ||
        localPath.startsWith('http://') ||
        localPath.startsWith('https://')) {
      return localPath;
    }

    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_shelf.jpg';
      final Reference ref = _storage.ref().child('scans').child(fileName);

      return await uploadScanImage(reference: ref, localPath: localPath)
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      return localPath;
    }
  }

  @override
  Future<void> deleteScan(String scanId) async {
    await _remoteDataSource.scansCollection.doc(scanId).delete();
  }

  Future<_UserDetails> _getUserDetails(ScanResultEntity scan) async {
    String? userEmail = scan.userEmail;
    String? userName = scan.userName;
    try {
      final userDoc = await _remoteDataSource.usersCollection.doc(scan.userId).get();
      final userData = userDoc.data();
      if (userData != null) {
        userEmail ??= userData['email'] as String?;
        userName ??= userData['name'] as String?;
      }
    } catch (_) {}
    return _UserDetails(userEmail, userName);
  }

  Future<void> _updateUserStatsOnCreate(String userId, int compliance) async {
    try {
      final userDocRef = _remoteDataSource.usersCollection.doc(userId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        if (!snapshot.exists) return;
        final data = snapshot.data();
        if (data == null) return;

        final int currentShifts = data['shiftsCompleted'] as int? ?? 0;
        final double currentAccuracy =
            (data['scanAccuracy'] as num?)?.toDouble() ?? 95.0;
        final newShifts = currentShifts + 1;
        final newAccuracy = ((currentAccuracy * currentShifts) + compliance) /
            newShifts;
        transaction.update(userDocRef, {
          'shiftsCompleted': newShifts,
          'scanAccuracy': double.parse(newAccuracy.toStringAsFixed(1)),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (_) {}
  }

  ScanResultModel _toModel(ScanResultEntity scan) {
    return ScanResultModel(
      id: scan.id,
      userId: scan.userId,
      userEmail: scan.userEmail,
      userName: scan.userName,
      title: scan.title,
      timestamp: scan.timestamp,
      imagePath: scan.imagePath,
      productCount: scan.productCount,
      shareOfShelf: scan.shareOfShelf,
      onShelfAvailability: scan.onShelfAvailability,
      compliance: scan.compliance,
      recommendation: scan.recommendation,
    );
  }
}

class _UserDetails {
  const _UserDetails(this.email, this.name);
  final String? email;
  final String? name;
}
