import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/services/food_camera_service.dart';
import 'package:floww/core/nutrition/services/food_scan_service.dart';
import 'package:floww/core/nutrition/services/photo_library_service.dart';

enum FoodScanStatus {
  starting,
  ready,
  capturing,
  picking,
  scanning,
  suspended,
  unavailable,
}

class FoodScanViewModel extends ChangeNotifier with WidgetsBindingObserver {
  FoodScanViewModel(
    this._cameraService,
    this._libraryService,
    this._scanService,
  ) {
    WidgetsBinding.instance.addObserver(this);
  }

  final FoodCameraService _cameraService;
  final PhotoLibraryService _libraryService;
  final FoodScanService _scanService;

  FoodScanStatus _status = FoodScanStatus.starting;
  String? _errorMessage;
  Uint8List? _scannedPhoto;
  bool _wasBackgrounded = false;
  bool _disposed = false;

  String? get errorMessage => _errorMessage;

  Uint8List? get scannedPhoto => _scannedPhoto;

  CameraController? get cameraController => _cameraService.controller;

  bool get isScanning => _status == FoodScanStatus.scanning;

  bool get canCapture => _status == FoodScanStatus.ready;

  bool get canPickPhoto =>
      _status == FoodScanStatus.ready || _status == FoodScanStatus.unavailable;

  bool get showShutter => _status != FoodScanStatus.unavailable;

  Future<void> startCamera() async {
    _status = FoodScanStatus.starting;
    _errorMessage = null;
    notifyListeners();

    try {
      await _cameraService.start();
      if (_disposed) {
        await _cameraService.stop();
        return;
      }
      _status = FoodScanStatus.ready;
    } on FoodCameraException catch (e) {
      _status = FoodScanStatus.unavailable;
      _errorMessage = e.message;
    }
    notifyListeners();
  }

  Future<FoodModel?> captureAndScan() async {
    if (!canCapture) return null;
    return _scanPhoto(_cameraService.capture, FoodScanStatus.capturing);
  }

  Future<FoodModel?> pickPhotoAndScan() async {
    if (!canPickPhoto) return null;
    final food = await _scanPhoto(
      _libraryService.pickPhoto,
      FoodScanStatus.picking,
      showsPhoto: true,
    );
    if (food == null &&
        _errorMessage == null &&
        _status == FoodScanStatus.ready) {
      await startCamera();
    }
    return food;
  }

  Future<FoodModel?> _scanPhoto(
    Future<Uint8List?> Function() readPhoto,
    FoodScanStatus readingStatus, {
    bool showsPhoto = false,
  }) async {
    final previousStatus = _status;
    final previousError = _errorMessage;
    _errorMessage = null;
    _status = readingStatus;
    notifyListeners();

    try {
      final photo = await readPhoto();
      if (photo == null) {
        _errorMessage = previousError;
        _status = previousStatus;
        notifyListeners();
        return null;
      }
      if (showsPhoto) _scannedPhoto = photo;
      _status = FoodScanStatus.scanning;
      notifyListeners();
      return await _scanService.scanFood(
        imageBytes: photo,
        mimeType: FoodCameraService.photoMimeType,
      );
    } on FoodCameraException catch (e) {
      _errorMessage = e.message;
    } on FoodScanException catch (e) {
      _errorMessage = e.message;
    }

    await _cameraService.resumePreview();
    _scannedPhoto = null;
    _status = previousStatus;
    notifyListeners();
    return null;
  }

  void _suspendCamera() {
    _status = FoodScanStatus.suspended;
    _cameraService.stop();
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        if (_status == FoodScanStatus.ready) _suspendCamera();
      case AppLifecycleState.paused:
        _wasBackgrounded = true;
      case AppLifecycleState.resumed:
        final shouldRestart =
            _status == FoodScanStatus.suspended ||
            (_status == FoodScanStatus.unavailable && _wasBackgrounded);
        _wasBackgrounded = false;
        if (shouldRestart) startCamera();
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.stop();
    super.dispose();
  }
}
