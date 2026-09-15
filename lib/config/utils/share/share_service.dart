import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ShareErrorCode { captureFailed, saveFailed, shareFailed, permissionDenied }

class ShareException implements Exception {
  const ShareException(this.code, this.message);

  final ShareErrorCode code;
  final String message;

  @override
  String toString() => 'ShareException($code): $message';
}

class ShareService {
  const ShareService();

  static const String _albumName = 'Floww';
  static const String _fileExtension = '.png';
  static const String _mimeType = 'image/png';

  Future<File> writeTempImage(Uint8List bytes, {required String name}) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$name$_fileExtension');
      return await file.writeAsBytes(bytes, flush: true);
    } catch (e, stackTrace) {
      debugPrint('writeTempImage failed: $e\n$stackTrace');
      throw const ShareException(
        ShareErrorCode.shareFailed,
        'Could not prepare your card. Please try again.',
      );
    }
  }

  Future<void> shareImage(
    Uint8List bytes, {
    required String name,
    String? text,
  }) async {
    final file = await writeTempImage(bytes, name: name);
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: [XFile(file.path, mimeType: _mimeType)],
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('shareImage failed: $e\n$stackTrace');
      throw const ShareException(
        ShareErrorCode.shareFailed,
        'Could not open the share sheet. Please try again.',
      );
    }
  }

  Future<void> saveImageToGallery(Uint8List bytes, {required String name}) async {
    try {
      if (!await Gal.hasAccess(toAlbum: true)) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          throw const ShareException(
            ShareErrorCode.permissionDenied,
            'Allow photo access to save your card.',
          );
        }
      }
      await Gal.putImageBytes(bytes, album: _albumName, name: name);
    } on ShareException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('saveImageToGallery failed: $e\n$stackTrace');
      throw const ShareException(
        ShareErrorCode.saveFailed,
        'Could not save your card. Please try again.',
      );
    }
  }
}
