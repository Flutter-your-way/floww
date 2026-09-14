import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/services/food_camera_service.dart';
import 'package:floww/core/nutrition/services/food_scan_service.dart';
import 'package:floww/core/nutrition/services/photo_library_service.dart';
import 'package:floww/core/nutrition/view_models/food_scan_view_model.dart';

class _FakeCameraService implements FoodCameraService {
  _FakeCameraService({this.startError, this.captureError});

  final FoodCameraException? startError;
  final FoodCameraException? captureError;

  int startCount = 0;
  int stopCount = 0;
  int resumeCount = 0;

  @override
  CameraController? get controller => null;

  @override
  Future<void> start() async {
    startCount++;
    if (startError != null) throw startError!;
  }

  @override
  Future<Uint8List> capture() async {
    if (captureError != null) throw captureError!;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<void> resumePreview() async => resumeCount++;

  @override
  Future<void> stop() async => stopCount++;
}

class _FakeLibraryService implements PhotoLibraryService {
  _FakeLibraryService({this.photo, this.pickError});

  final Uint8List? photo;
  final FoodCameraException? pickError;

  int pickCount = 0;

  @override
  Future<Uint8List?> pickPhoto() async {
    pickCount++;
    if (pickError != null) throw pickError!;
    return photo;
  }
}

class _FakeScanService implements FoodScanService {
  _FakeScanService({this.result, this.error});

  final FoodModel? result;
  final FoodScanException? error;

  String? lastMimeType;

  @override
  Future<FoodModel> scanFood({
    required Uint8List imageBytes,
    required String mimeType,
    String? note,
  }) async {
    lastMimeType = mimeType;
    if (error != null) throw error!;
    return result!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FoodModel food;

  setUpAll(() {
    food = FoodModel.fromJson(
      jsonDecode(File('test/fixtures/food_model.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  test('starting the camera enables capture', () async {
    final viewModel = FoodScanViewModel(
      _FakeCameraService(),
      _FakeLibraryService(),
      _FakeScanService(result: food),
    );

    expect(viewModel.canCapture, isFalse);
    await viewModel.startCamera();

    expect(viewModel.canCapture, isTrue);
    expect(viewModel.showShutter, isTrue);
    expect(viewModel.errorMessage, isNull);
    viewModel.dispose();
  });

  test('denied camera hides the shutter and shows the reason', () async {
    final viewModel = FoodScanViewModel(
      _FakeCameraService(
        startError: FoodCameraException(
          FoodCameraErrorCode.permissionDenied,
          'Camera access is off.',
        ),
      ),
      _FakeLibraryService(),
      _FakeScanService(result: food),
    );

    await viewModel.startCamera();

    expect(viewModel.canCapture, isFalse);
    expect(viewModel.showShutter, isFalse);
    expect(viewModel.errorMessage, 'Camera access is off.');
    viewModel.dispose();
  });

  test('capture scans the photo and returns the food', () async {
    final scanService = _FakeScanService(result: food);
    final viewModel = FoodScanViewModel(
      _FakeCameraService(),
      _FakeLibraryService(),
      scanService,
    );
    await viewModel.startCamera();

    final result = await viewModel.captureAndScan();

    expect(result, same(food));
    expect(scanService.lastMimeType, FoodCameraService.photoMimeType);
    expect(viewModel.isScanning, isTrue);
    expect(viewModel.canCapture, isFalse);
    viewModel.dispose();
  });

  test('failed scan shows the error and resumes the preview', () async {
    final cameraService = _FakeCameraService();
    final viewModel = FoodScanViewModel(
      cameraService,
      _FakeLibraryService(),
      _FakeScanService(
        error: FoodScanException(
          FoodScanErrorCode.notFood,
          'That does not look like food.',
        ),
      ),
    );
    await viewModel.startCamera();

    final result = await viewModel.captureAndScan();

    expect(result, isNull);
    expect(viewModel.errorMessage, 'That does not look like food.');
    expect(viewModel.isScanning, isFalse);
    expect(viewModel.canCapture, isTrue);
    expect(cameraService.resumeCount, 1);
    viewModel.dispose();
  });

  test('failed capture shows the error and never calls the scan', () async {
    final scanService = _FakeScanService(result: food);
    final viewModel = FoodScanViewModel(
      _FakeCameraService(
        captureError: FoodCameraException(
          FoodCameraErrorCode.captureFailed,
          'Could not take the photo.',
        ),
      ),
      _FakeLibraryService(),
      scanService,
    );
    await viewModel.startCamera();

    final result = await viewModel.captureAndScan();

    expect(result, isNull);
    expect(scanService.lastMimeType, isNull);
    expect(viewModel.errorMessage, 'Could not take the photo.');
    expect(viewModel.canCapture, isTrue);
    viewModel.dispose();
  });

  test('a library photo is scanned even without a camera', () async {
    final scanService = _FakeScanService(result: food);
    final libraryService = _FakeLibraryService(
      photo: Uint8List.fromList([4, 5, 6]),
    );
    final viewModel = FoodScanViewModel(
      _FakeCameraService(
        startError: FoodCameraException(
          FoodCameraErrorCode.unavailable,
          'No camera found on this device.',
        ),
      ),
      libraryService,
      scanService,
    );
    await viewModel.startCamera();

    expect(viewModel.showShutter, isFalse);
    expect(viewModel.canPickPhoto, isTrue);

    final result = await viewModel.pickPhotoAndScan();

    expect(result, same(food));
    expect(libraryService.pickCount, 1);
    expect(scanService.lastMimeType, FoodCameraService.photoMimeType);
    expect(viewModel.scannedPhoto, [4, 5, 6]);
    viewModel.dispose();
  });

  test('a failed library scan drops the photo and shows the error', () async {
    final viewModel = FoodScanViewModel(
      _FakeCameraService(),
      _FakeLibraryService(photo: Uint8List.fromList([4, 5, 6])),
      _FakeScanService(
        error: FoodScanException(
          FoodScanErrorCode.notFood,
          'That does not look like food.',
        ),
      ),
    );
    await viewModel.startCamera();

    expect(await viewModel.pickPhotoAndScan(), isNull);

    expect(viewModel.scannedPhoto, isNull);
    expect(viewModel.errorMessage, 'That does not look like food.');
    expect(viewModel.canCapture, isTrue);
    viewModel.dispose();
  });

  test('camera captures keep the frozen preview instead of a photo', () async {
    final viewModel = FoodScanViewModel(
      _FakeCameraService(),
      _FakeLibraryService(),
      _FakeScanService(result: food),
    );
    await viewModel.startCamera();

    expect(await viewModel.captureAndScan(), same(food));

    expect(viewModel.scannedPhoto, isNull);
    viewModel.dispose();
  });

  test('cancelling the picker restores the previous state', () async {
    final cameraService = _FakeCameraService(
      startError: FoodCameraException(
        FoodCameraErrorCode.unavailable,
        'No camera found on this device.',
      ),
    );
    final scanService = _FakeScanService(result: food);
    final viewModel = FoodScanViewModel(
      cameraService,
      _FakeLibraryService(),
      scanService,
    );
    await viewModel.startCamera();

    final result = await viewModel.pickPhotoAndScan();

    expect(result, isNull);
    expect(scanService.lastMimeType, isNull);
    expect(viewModel.errorMessage, 'No camera found on this device.');
    expect(viewModel.canPickPhoto, isTrue);
    expect(cameraService.startCount, 1);
    viewModel.dispose();
  });

  test('cancelling the picker restarts the live preview', () async {
    final cameraService = _FakeCameraService();
    final viewModel = FoodScanViewModel(
      cameraService,
      _FakeLibraryService(),
      _FakeScanService(result: food),
    );
    await viewModel.startCamera();

    expect(await viewModel.pickPhotoAndScan(), isNull);

    expect(cameraService.startCount, 2);
    expect(viewModel.canCapture, isTrue);
    expect(viewModel.errorMessage, isNull);
    viewModel.dispose();
  });

  test('a failed picker shows the error and keeps the camera', () async {
    final cameraService = _FakeCameraService();
    final viewModel = FoodScanViewModel(
      cameraService,
      _FakeLibraryService(
        pickError: FoodCameraException(
          FoodCameraErrorCode.captureFailed,
          'Could not open your photo library.',
        ),
      ),
      _FakeScanService(result: food),
    );
    await viewModel.startCamera();

    expect(await viewModel.pickPhotoAndScan(), isNull);

    expect(viewModel.errorMessage, 'Could not open your photo library.');
    expect(viewModel.canCapture, isTrue);
    expect(cameraService.startCount, 1);
    viewModel.dispose();
  });

  test('camera is released when inactive and restarted on resume', () async {
    final cameraService = _FakeCameraService();
    final viewModel = FoodScanViewModel(
      cameraService,
      _FakeLibraryService(),
      _FakeScanService(result: food),
    );
    await viewModel.startCamera();

    viewModel.didChangeAppLifecycleState(AppLifecycleState.inactive);
    expect(cameraService.stopCount, 1);
    expect(viewModel.canCapture, isFalse);

    viewModel.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await pumpEventQueue();
    expect(cameraService.startCount, 2);
    expect(viewModel.canCapture, isTrue);
    viewModel.dispose();
  });

  test(
    'unavailable camera retries only after the app was backgrounded',
    () async {
      final cameraService = _FakeCameraService(
        startError: FoodCameraException(
          FoodCameraErrorCode.permissionDenied,
          'Camera access is off.',
        ),
      );
      final viewModel = FoodScanViewModel(
        cameraService,
        _FakeLibraryService(),
        _FakeScanService(result: food),
      );
      await viewModel.startCamera();

      viewModel.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();
      expect(cameraService.startCount, 1);

      viewModel.didChangeAppLifecycleState(AppLifecycleState.paused);
      viewModel.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();
      expect(cameraService.startCount, 2);
      viewModel.dispose();
    },
  );

  test('dispose releases the camera', () async {
    final cameraService = _FakeCameraService();
    final viewModel = FoodScanViewModel(
      cameraService,
      _FakeLibraryService(),
      _FakeScanService(result: food),
    );
    await viewModel.startCamera();

    viewModel.dispose();

    expect(cameraService.stopCount, 1);
  });
}
