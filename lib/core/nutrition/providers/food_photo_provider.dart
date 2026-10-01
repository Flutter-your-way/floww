import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:floww/config/widgets/sheets/app_option_sheet.dart';
import 'package:floww/core/nutrition/models/food_image_key.dart';
import 'package:floww/core/nutrition/models/food_photo_catalog.dart';
import 'package:floww/core/nutrition/models/food_photo_source.dart';
import 'package:floww/core/nutrition/services/food_image_service.dart';

class FoodPhotoProvider extends ChangeNotifier {
  FoodPhotoProvider(this._service);

  final FoodImageService _service;

  StreamSubscription<String?>? _userWatch;
  StreamSubscription<Map<String, String>>? _overridesWatch;
  Map<String, String> _overrides = const {};
  final Map<String, String?> _lookups = {};
  final Set<String> _pending = {};
  final Set<String> _failed = {};
  final Set<String> _updating = {};
  bool _disposed = false;

  Future<void> start() async {
    _lookups.addAll(await _service.loadLookups());
    _notify();
    await _userWatch?.cancel();
    _userWatch = _service.watchUserId().listen(_onUser);
  }

  String? urlFor(String name) {
    final key = FoodImageKey.of(name);
    if (key.isEmpty) return null;
    final override = _overrides[key];
    if (override != null) return override;
    final common = FoodPhotoCatalog.of(key);
    if (common != null) return common;
    if (_lookups.containsKey(key)) return _lookups[key];
    _requestLookup(key, name);
    return null;
  }

  bool isUpdating(String name) => _updating.contains(FoodImageKey.of(name));

  List<AppSheetOption<FoodPhotoAction>> optionsFor(String name) => [
    const AppSheetOption(
      icon: Icons.photo_camera_outlined,
      label: 'Take photo',
      value: FoodPhotoAction.takePhoto,
    ),
    const AppSheetOption(
      icon: Icons.photo_library_outlined,
      label: 'Choose from library',
      value: FoodPhotoAction.chooseFromLibrary,
    ),
    if (_overrides.containsKey(FoodImageKey.of(name)))
      const AppSheetOption(
        icon: Icons.restart_alt_rounded,
        label: 'Use default photo',
        value: FoodPhotoAction.useDefault,
        isDestructive: true,
      ),
  ];

  Future<void> apply(String name, FoodPhotoAction action) async {
    switch (action) {
      case FoodPhotoAction.takePhoto:
        await _replaceFrom(name, FoodPhotoSource.camera);
      case FoodPhotoAction.chooseFromLibrary:
        await _replaceFrom(name, FoodPhotoSource.library);
      case FoodPhotoAction.useDefault:
        await _reset(name);
    }
  }

  Future<Uint8List?> pick(FoodPhotoSource source) => _service.pick(source);

  Future<void> savePhoto(
    String name,
    Uint8List bytes,
    FoodPhotoSource source,
  ) async {
    final key = FoodImageKey.of(name);
    if (key.isEmpty) return;
    _updating.add(key);
    _notify();
    try {
      final url = await _service.upload(
        key: key,
        name: name,
        bytes: bytes,
        source: source,
      );
      _overrides = {..._overrides, key: url};
    } finally {
      _updating.remove(key);
      _notify();
    }
  }

  Future<void> _replaceFrom(String name, FoodPhotoSource source) async {
    final bytes = await _service.pick(source);
    if (bytes == null) return;
    await savePhoto(name, bytes, source);
  }

  Future<void> _reset(String name) async {
    final key = FoodImageKey.of(name);
    _updating.add(key);
    _notify();
    try {
      await _service.reset(key);
      _overrides = {..._overrides}..remove(key);
    } finally {
      _updating.remove(key);
      _notify();
    }
  }

  void _onUser(String? uid) {
    _overridesWatch?.cancel();
    _overridesWatch = null;
    _overrides = const {};
    _notify();
    if (uid == null) return;
    _overridesWatch = _service.watchOverrides(uid).listen(
      (overrides) {
        _overrides = overrides;
        _notify();
      },
      onError: (Object error) =>
          debugPrint('food photo overrides watch failed: $error'),
    );
  }

  void _requestLookup(String key, String name) {
    if (_failed.contains(key) || !_pending.add(key)) return;
    scheduleMicrotask(() => _lookup(key, name));
  }

  Future<void> _lookup(String key, String name) async {
    try {
      _lookups[key] = await _service.lookup(name);
      unawaited(_service.saveLookups(Map.of(_lookups)));
      _notify();
    } on FoodImageException catch (e) {
      debugPrint('food photo lookup failed for $name: $e');
      _failed.add(key);
    } finally {
      _pending.remove(key);
    }
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _userWatch?.cancel();
    _overridesWatch?.cancel();
    super.dispose();
  }
}
