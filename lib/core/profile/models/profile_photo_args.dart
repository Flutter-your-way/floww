import 'dart:typed_data';

class ProfilePhotoArgs {
  const ProfilePhotoArgs({required this.title, this.imageUrl, this.imageBytes});

  final String title;
  final String? imageUrl;
  final Uint8List? imageBytes;

  bool get hasImage => imageUrl != null || imageBytes != null;
}
