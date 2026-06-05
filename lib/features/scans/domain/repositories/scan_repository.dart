import 'package:shelf_sight_ui_implementation/features/scans/domain/entities/scan_result_entity.dart';

abstract class ScanRepository {
  Future<ScanResultEntity> saveScan(ScanResultEntity scan);

  Future<ScanResultEntity> updateScan(ScanResultEntity scan);

  Future<List<ScanResultEntity>> getScansForUser(String userId);

  Stream<List<ScanResultEntity>> streamScansForUser(String userId);

  Future<List<ScanResultEntity>> getAllScans();

  Stream<List<ScanResultEntity>> streamAllScans();

  Future<String> uploadImage(String localPath);

  Future<void> deleteScan(String scanId);
}
