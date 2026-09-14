import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:floww/core/nutrition/services/food_camera_service.dart';

class PhotoLibraryService {
  static const double _maxDimension = 1280;
  static const int _imageQuality = 85;

  final ImagePicker _picker = ImagePicker();

  Future<Uint8List?> pickPhoto() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxDimension,
        maxHeight: _maxDimension,
        imageQuality: _imageQuality,
      );
      return await photo?.readAsBytes();
    } catch (e, stackTrace) {
      debugPrint('pickPhoto failed: $e\n$stackTrace');
      throw FoodCameraException(
        FoodCameraErrorCode.captureFailed,
        'Could not open your photo library. Please try again.',
      );
    }
  }
}
