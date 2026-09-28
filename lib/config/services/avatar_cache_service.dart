import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:floww/config/constants/app_storage.dart';

class AvatarCacheService {
  AvatarCacheService._();

  static final AvatarCacheService instance = AvatarCacheService._();

  static const String _directoryName = 'avatar_cache';
  static const Duration _timeout = Duration(seconds: 30);

  final Map<String, Uint8List> _memory = {};
  final Map<String, Future<Uint8List?>> _pending = {};
  final HttpClient _client = HttpClient()..connectionTimeout = _timeout;
  Directory? _directory;

  Uint8List? peek(String url) => _memory[url];

  Future<Uint8List?> load(String url) {
    final cached = _memory[url];
    if (cached != null) return SynchronousFuture(cached);
    return _pending[url] ??= _resolve(url).whenComplete(() {
      _pending.remove(url);
    });
  }

  void prefetch(String? url) {
    if (url == null) return;
    unawaited(load(url));
  }

  Future<void> store(String url, Uint8List bytes) async {
    _memory[url] = bytes;
    try {
      await _write(await _fileFor(url), bytes);
    } catch (e) {
      debugPrint('avatar cache store failed: $e');
    }
    await retainOnly(url);
  }

  Future<Uint8List?> _resolve(String url) async {
    try {
      final file = await _fileFor(url);
      final cached = await file.exists() ? await file.readAsBytes() : null;
      final bytes = cached != null && cached.isNotEmpty
          ? cached
          : await _download(url);
      if (bytes.isEmpty) return null;
      _memory[url] = bytes;
      if (!identical(bytes, cached)) await _write(file, bytes);
      return bytes;
    } catch (e) {
      debugPrint('avatar cache failed for $url: $e');
      return null;
    }
  }

  Future<Uint8List> _download(String url) async {
    final reference = _storageReferenceOf(url);
    if (reference == null) return _downloadHttp(url);
    final bytes = await reference
        .getData(AppStorage.avatarMaxBytes)
        .timeout(_timeout);
    if (bytes == null) throw StateError('empty avatar download');
    return bytes;
  }

  Reference? _storageReferenceOf(String url) {
    try {
      return FirebaseStorage.instance.refFromURL(url);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _downloadHttp(String url) async {
    final request = await _client.getUrl(Uri.parse(url)).timeout(_timeout);
    final response = await request.close().timeout(_timeout);
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('status ${response.statusCode}', uri: request.uri);
    }
    return consolidateHttpClientResponseBytes(response).timeout(_timeout);
  }

  Future<void> _write(File file, Uint8List bytes) async {
    try {
      final temp = File('${file.path}.tmp');
      await temp.writeAsBytes(bytes, flush: true);
      await temp.rename(file.path);
    } catch (e) {
      debugPrint('avatar cache write failed: $e');
    }
  }

  Future<File> _fileFor(String url) async {
    final directory = _directory ??= await _createDirectory();
    final name = sha1.convert(utf8.encode(url)).toString();
    return File('${directory.path}/$name');
  }

  Future<Directory> _createDirectory() async {
    final support = await getApplicationSupportDirectory();
    return Directory('${support.path}/$_directoryName').create(recursive: true);
  }

  Future<void> retainOnly(String? url) async {
    _memory.removeWhere((key, _) => key != url);
    try {
      final directory = _directory ??= await _createDirectory();
      final keep = url == null ? null : (await _fileFor(url)).path;
      await for (final entity in directory.list()) {
        if (entity is File &&
            entity.path != keep &&
            !entity.path.endsWith('.tmp')) {
          await entity.delete();
        }
      }
    } catch (e) {
      debugPrint('avatar cache eviction failed: $e');
    }
  }
}
