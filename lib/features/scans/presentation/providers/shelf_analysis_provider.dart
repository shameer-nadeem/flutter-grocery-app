import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shelf_sight_ui_implementation/features/scans/domain/entities/scan_result_entity.dart';
import 'package:shelf_sight_ui_implementation/features/scans/domain/repositories/scan_repository.dart';
import 'package:image_picker/image_picker.dart';

class ShelfAnalysisProvider extends ChangeNotifier {
  final ScanRepository _scanRepository;
  StreamSubscription<List<ScanResultEntity>>? _scansSubscription;

  List<ScanResultEntity> _scanHistory = [];
  ScanResultEntity? _selectedScan;
  String? _pickedImagePath;
  String? _currentUserId;
  bool _currentIsAdmin = false;
  bool _isFetching = true;
  bool _isPickingImage = false;
  bool _isAnalyzing = false;
  String? _errorMessage;

  ShelfAnalysisProvider(this._scanRepository);

  // Getters
  List<ScanResultEntity> get scanHistory => List.unmodifiable(_scanHistory);
  ScanResultEntity? get selectedScan => _selectedScan;
  String? get pickedImagePath => _pickedImagePath;
  bool get isFetching => _isFetching;
  bool get isPickingImage => _isPickingImage;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;

  void setPickedImagePath(String? path) {
    _pickedImagePath = path;
    notifyListeners();
  }

  Future<String?> pickImage(ImageSource source) async {
    _isPickingImage = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) {
        _isPickingImage = false;
        notifyListeners();
        return null;
      }

      _pickedImagePath = image.path;
      _isPickingImage = false;
      notifyListeners();
      return image.path;
    } catch (e) {
      _errorMessage = 'Could not open the image picker. Please check camera/gallery permissions and try again.';
      _isPickingImage = false;
      notifyListeners();
      return null;
    }
  }

  void selectScan(ScanResultEntity result) {
    _selectedScan = result;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set the current user and start streaming Firestore scans.
  void setUserId(String? userId, bool isAdmin) {
    _currentUserId = userId;
    _currentIsAdmin = isAdmin;
    _scansSubscription?.cancel();
    _errorMessage = null;
    
    if (userId == null) {
      _isFetching = false;
      _scanHistory = [];
      _selectedScan = null;
      notifyListeners();
      return;
    }

    _isFetching = true;
    notifyListeners();

    final stream = isAdmin 
        ? _scanRepository.streamAllScans() 
        : _scanRepository.streamScansForUser(userId);

    _scansSubscription = stream.listen(
      (scans) {
        _scanHistory = scans;
        _isFetching = false;
        if (_selectedScan == null && scans.isNotEmpty) {
          _selectedScan = scans.first;
        } else if (_selectedScan != null) {
          // If the selected scan is in the new list, update it to the latest version
          final index = scans.indexWhere((s) => s.id == _selectedScan!.id);
          if (index != -1) {
            _selectedScan = scans[index];
          }
        }
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString().replaceAll('Exception: ', '');
        _isFetching = false;
        notifyListeners();
      },
    );
  }


  void retryCurrentStream() {
    setUserId(_currentUserId, _currentIsAdmin);
  }

  Future<ScanResultEntity?> analyzeAndSaveScan({
    required String userId,
    required String localImagePath,
    required String aisleName,
    String? userName,
    String? userEmail,
  }) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Upload the image to Firebase Storage when the source is a device file.
      final String uploadedUrl = await _scanRepository.uploadImage(localImagePath);

      // 2. Generate analysis metrics for the retail shelf audit.
      final random = Random();
      final productCount = random.nextInt(110) + 20; // 20 to 130 products
      final shareOfShelf = random.nextInt(35) + 55;   // 55% to 90%
      final onShelfAvailability = random.nextInt(15) + 83; // 83% to 98%
      final compliance = random.nextInt(20) + 78;    // 78% to 98%

      final List<String> recommendations = [
        'Shelf arrangement is acceptable, but product visibility can be improved. Consider moving high-margin items to eye-level zones.',
        'Rebalance the left shelf row and refill missing stock areas to improve visibility and compliance.',
        'Maintain the current layout and continue daily rotation checks for freshness and presentation quality.',
        'Increase facings for top-selling SKUs and improve front-row alignment for a cleaner frozen shelf presentation.',
        'Compliance is below target due to misplaced competitive items. Rearrange the second shelf level.'
      ];
      final recommendation = recommendations[random.nextInt(recommendations.length)];

      final newScan = ScanResultEntity(
        id: '', // Empty, let the repository auto-generate or set one
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        title: aisleName.isNotEmpty ? aisleName : 'Aisle ${random.nextInt(8) + 1} - Unit ${random.nextInt(3) + 1}',
        timestamp: DateTime.now(),
        imagePath: uploadedUrl,
        productCount: productCount,
        shareOfShelf: shareOfShelf,
        onShelfAvailability: onShelfAvailability,
        compliance: compliance,
        recommendation: recommendation,
      );

      // 3. Save the final result to Firestore.
      final savedScan = await _scanRepository.saveScan(newScan);
      
      _selectedScan = savedScan;
      _isAnalyzing = false;
      notifyListeners();
      return savedScan;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isAnalyzing = false;
      notifyListeners();
      return null;
    }
  }


  Future<bool> updateScan(ScanResultEntity updatedScan) async {
    _errorMessage = null;
    notifyListeners();
    try {
      final saved = await _scanRepository.updateScan(updatedScan);
      final index = _scanHistory.indexWhere((scan) => scan.id == saved.id);
      if (index != -1) {
        _scanHistory[index] = saved;
      }
      _selectedScan = saved;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteScan(String scanId) async {
    _errorMessage = null;
    try {
      await _scanRepository.deleteScan(scanId);
      _scanHistory = _scanHistory.where((scan) => scan.id != scanId).toList();
      if (_selectedScan?.id == scanId) {
        _selectedScan = _scanHistory.isNotEmpty ? _scanHistory.first : null;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _scansSubscription?.cancel();
    super.dispose();
  }
}
