import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ShareErrorCode {
  captureFailed,
  saveFailed,
  shareFailed,
  openFailed,
  permissionDenied,
}

enum SavedFileLocation { downloads, appFolder }

class SavedFile {
  const SavedFile({
    required this.name,
    required this.path,
    required this.location,
  });

  final String name;
  final String path;
  final SavedFileLocation location;
}

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
  static const String _downloadsFolder = 'Floww';
  static const int _maxNameAttempts = 100;

  static bool _mediaStoreReady = false;

  Future<File> writeTempFile(
    Uint8List bytes, {
    required String name,
    required String extension,
    String failureMessage = 'Could not prepare your file. Please try again.',
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$name$extension');
      return await file.writeAsBytes(bytes, flush: true);
    } catch (e, stackTrace) {
      debugPrint('writeTempFile failed: $e\n$stackTrace');
      throw ShareException(ShareErrorCode.saveFailed, failureMessage);
    }
  }

  Future<SavedFile> saveFile(
    Uint8List bytes, {
    required String name,
    required String extension,
    String failureMessage = 'Could not save your file. Please try again.',
  }) async {
    final File file;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final target = _availableFile(directory, name, extension);
      file = await target.writeAsBytes(bytes, flush: true);
    } catch (e, stackTrace) {
      debugPrint('saveFile failed: $e\n$stackTrace');
      throw ShareException(ShareErrorCode.saveFailed, failureMessage);
    }

    final publishedName = Platform.isAndroid
        ? await _publishToDownloads(bytes, name: name, extension: extension)
        : null;

    return SavedFile(
      name: publishedName ?? _baseName(file.path),
      path: file.path,
      location: publishedName == null
          ? SavedFileLocation.appFolder
          : SavedFileLocation.downloads,
    );
  }

  Future<String?> _publishToDownloads(
    Uint8List bytes, {
    required String name,
    required String extension,
  }) async {
    try {
      final temp = await writeTempFile(bytes, name: name, extension: extension);
      if (!_mediaStoreReady) {
        await MediaStore.ensureInitialized();
        _mediaStoreReady = true;
      }
      MediaStore.appFolder = _downloadsFolder;
      final info = await MediaStore().saveFile(
        tempFilePath: temp.path,
        dirType: DirType.download,
        dirName: DirName.download,
      );
      return info?.name;
    } catch (e, stackTrace) {
      debugPrint('publishToDownloads failed: $e\n$stackTrace');
      return null;
    }
  }

  Future<void> openFile(String path, {String? mimeType}) async {
    final result = await OpenFilex.open(path, type: mimeType);
    if (result.type == ResultType.done) return;

    debugPrint('openFile failed: ${result.type} ${result.message}');
    throw const ShareException(
      ShareErrorCode.openFailed,
      'Saved, but no app on this device could open the PDF.',
    );
  }

  String _baseName(String path) => path.split(Platform.pathSeparator).last;

  File _availableFile(Directory directory, String name, String extension) {
    final file = File('${directory.path}/$name$extension');
    if (!file.existsSync()) return file;

    for (var attempt = 2; attempt <= _maxNameAttempts; attempt++) {
      final candidate = File('${directory.path}/$name-$attempt$extension');
      if (!candidate.existsSync()) return candidate;
    }
    return file;
  }

  Future<void> shareFile(
    Uint8List bytes, {
    required String name,
    required String extension,
    required String mimeType,
    String? text,
    String failureMessage = 'Could not prepare your file. Please try again.',
  }) async {
    final file = await writeTempFile(
      bytes,
      name: name,
      extension: extension,
      failureMessage: failureMessage,
    );
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: [XFile(file.path, mimeType: mimeType)],
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('shareFile failed: $e\n$stackTrace');
      throw const ShareException(
        ShareErrorCode.shareFailed,
        'Could not open the share sheet. Please try again.',
      );
    }
  }

  Future<File> writeTempImage(Uint8List bytes, {required String name}) =>
      writeTempFile(
        bytes,
        name: name,
        extension: _fileExtension,
        failureMessage: 'Could not prepare your card. Please try again.',
      );

  Future<void> shareImage(
    Uint8List bytes, {
    required String name,
    String? text,
  }) => shareFile(
    bytes,
    name: name,
    extension: _fileExtension,
    mimeType: _mimeType,
    text: text,
    failureMessage: 'Could not prepare your card. Please try again.',
  );

  Future<void> saveImageToGallery(
    Uint8List bytes, {
    required String name,
  }) async {
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
