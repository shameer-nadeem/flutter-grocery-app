class ScanResultEntity {
  const ScanResultEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.timestamp,
    required this.imagePath,
    required this.productCount,
    required this.shareOfShelf,
    required this.onShelfAvailability,
    required this.compliance,
    required this.recommendation,
    this.userEmail,
    this.userName,
  });

  final String id;
  final String userId;
  final String title;
  final DateTime timestamp;
  final String imagePath;
  final int productCount;
  final int shareOfShelf;
  final int onShelfAvailability;
  final int compliance;
  final String recommendation;
  final String? userEmail;
  final String? userName;

  ScanResultEntity copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? timestamp,
    String? imagePath,
    int? productCount,
    int? shareOfShelf,
    int? onShelfAvailability,
    int? compliance,
    String? recommendation,
    String? userEmail,
    String? userName,
  }) {
    return ScanResultEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      imagePath: imagePath ?? this.imagePath,
      productCount: productCount ?? this.productCount,
      shareOfShelf: shareOfShelf ?? this.shareOfShelf,
      onShelfAvailability: onShelfAvailability ?? this.onShelfAvailability,
      compliance: compliance ?? this.compliance,
      recommendation: recommendation ?? this.recommendation,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
    );
  }

  String get subtitle {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[timestamp.month - 1];
    final day = timestamp.day;
    final year = timestamp.year;

    var hour = timestamp.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final minuteStr = timestamp.minute.toString().padLeft(2, '0');
    final hourStr = hour.toString().padLeft(2, '0');

    return '$month $day, $year • $hourStr:$minuteStr $ampm';
  }
}
