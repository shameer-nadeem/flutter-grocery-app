import 'package:shelf_sight_ui_implementation/features/scans/domain/entities/scan_result_entity.dart';

class ScanResultModel extends ScanResultEntity {
  const ScanResultModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.timestamp,
    required super.imagePath,
    required super.productCount,
    required super.shareOfShelf,
    required super.onShelfAvailability,
    required super.compliance,
    required super.recommendation,
    super.userEmail,
    super.userName,
  });

  factory ScanResultModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedTimestamp;
    final tsValue = map['createdAt'] ?? map['timestamp'];
    if (tsValue is int) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(tsValue);
    } else if (tsValue is String) {
      parsedTimestamp = DateTime.tryParse(tsValue) ?? DateTime.now();
    } else if (tsValue != null && tsValue.runtimeType.toString().contains('Timestamp')) {
      // Handles Firestore Timestamp dynamically
      try {
        parsedTimestamp = (tsValue as dynamic).toDate() as DateTime;
      } catch (e) {
        parsedTimestamp = DateTime.now();
      }
    } else {
      parsedTimestamp = DateTime.now();
    }

    return ScanResultModel(
      id: map['scanId'] as String? ?? id,
      userId: map['userId'] as String? ?? '',
      userEmail: map['userEmail'] as String?,
      userName: map['userName'] as String?,
      title: map['title'] as String? ?? '',
      timestamp: parsedTimestamp,
      imagePath: (map['imageUrl'] ?? map['imagePath']) as String? ?? '',
      productCount: map['productCount'] as int? ?? 0,
      shareOfShelf: (map['sosPercentage'] ?? map['shareOfShelf']) as int? ?? 0,
      onShelfAvailability: (map['osaPercentage'] ?? map['onShelfAvailability']) as int? ?? 0,
      compliance: (map['compliancePercentage'] ?? map['compliance']) as int? ?? 0,
      recommendation: map['recommendation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scanId': id,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'title': title,
      'createdAt': timestamp.millisecondsSinceEpoch,
      'imageUrl': imagePath,
      'productCount': productCount,
      'sosPercentage': shareOfShelf,
      'osaPercentage': onShelfAvailability,
      'compliancePercentage': compliance,
      'recommendation': recommendation,
    };
  }
}
