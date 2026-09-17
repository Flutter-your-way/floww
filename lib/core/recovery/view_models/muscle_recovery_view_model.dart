import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/recovery/models/muscle_body_side.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/models/muscle_hit_region.dart';
import 'package:floww/core/recovery/models/muscle_recovery_item.dart';
import 'package:floww/core/recovery/models/muscle_recovery_status.dart';
import 'package:floww/core/recovery/services/muscle_map_data.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/recovery/services/muscle_recovery_service.dart';

class MuscleRecoveryViewModel extends ChangeNotifier {
  MuscleRecoveryViewModel(this._recoveryService, this._mapService) {
    _load();
  }

  final MuscleRecoveryService _recoveryService;
  final MuscleMapService _mapService;

  final Map<MuscleGroup, MuscleRecoveryItem> _itemsByGroup = {};
  List<MuscleRecoveryItem> _items = const [];
  StreamSubscription<MuscleRecoverySnapshot>? _subscription;
  DateTime? _lastWorkoutAt;
  bool _mapLoaded = false;
  bool _hasSnapshot = false;
  bool _disposed = false;

  MuscleBodySide _side = MuscleBodySide.front;
  MuscleGroup? _selectedGroup;
  Offset _selectionAnchor = Offset.zero;
  MuscleRecoveryStatus? _filter;

  bool get isReady => _mapLoaded && _hasSnapshot;

  List<MuscleRecoveryItem> get items => _items;

  MuscleBodySide get side => _side;

  MuscleRecoveryStatus? get filter => _filter;

  Offset get selectionAnchor => _selectionAnchor;

  MuscleRecoveryItem? get selected => _itemsByGroup[_selectedGroup];

  Size get viewBox => MuscleMapData.viewBoxes[_side]!;

  MuscleMapTemplate? get template => templateOf(_side);

  MuscleMapTemplate? templateOf(MuscleBodySide side) =>
      _mapService.templateOf(side);

  Map<MuscleGroup, MuscleRecoveryStatus> get statuses => {
    for (final item in _items) item.group: item.status,
  };

  List<MuscleRecoveryItem> get filteredItems {
    final filter = _filter;
    if (filter == null) return _items;
    return _items.where((item) => item.status == filter).toList();
  }

  int countOf(MuscleRecoveryStatus status) =>
      _items.where((item) => item.status == status).length;

  MuscleRecoveryItem? itemOf(MuscleGroup group) => _itemsByGroup[group];

  String get lastWorkoutLabel {
    final lastWorkoutAt = _lastWorkoutAt;
    if (lastWorkoutAt == null) return 'No Workout Logged Yet';

    final elapsed = DateTime.now().difference(lastWorkoutAt);
    if (elapsed.inMinutes < 1) return 'Moments Since Last Workout';
    if (elapsed.inHours < 1) {
      return '${_plural(elapsed.inMinutes, 'Minute')} Since Last Workout';
    }
    if (elapsed.inDays < 1) {
      return '${_plural(elapsed.inHours, 'Hour')} Since Last Workout';
    }
    return '${_plural(elapsed.inDays, 'Day')} Since Last Workout';
  }

  String subtitleOf(MuscleRecoveryItem item) {
    final lastTrainedAt = item.lastTrainedAt;
    if (lastTrainedAt == null) return 'No recent exercises';
    return AppDateUtils.relativeDay(lastTrainedAt);
  }

  void selectSide(MuscleBodySide side) {
    if (_side == side) return;
    _side = side;
    _selectDefault();
    notifyListeners();
  }

  void selectAt(Offset point) {
    final region = _regionAt(point);
    if (region == null) return;
    _selectedGroup = region.group;
    _selectionAnchor = point;
    notifyListeners();
  }

  void setFilter(MuscleRecoveryStatus? filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  MuscleHitRegion? _regionAt(Offset point) {
    for (final region in MuscleMapData.hitRegions[_side]!) {
      if (region.bounds.contains(point)) return region;
    }
    return null;
  }

  void _selectDefault() {
    final regions = MuscleMapData.hitRegions[_side]!;
    MuscleGroup? weakest;
    Rect? bounds;
    for (final region in regions) {
      final item = _itemsByGroup[region.group];
      if (item == null) continue;
      final current = _itemsByGroup[weakest];
      if (current == null || item.percent < current.percent) {
        weakest = region.group;
        bounds = region.bounds;
      } else if (region.group == weakest) {
        bounds = bounds!.expandToInclude(region.bounds);
      }
    }
    _selectedGroup = weakest;
    _selectionAnchor = bounds == null
        ? Offset.zero
        : Offset(viewBox.width / 2, bounds.center.dy);
  }

  Future<void> _load() async {
    _subscription = _recoveryService.watch().listen(
      _apply,
      onError: (Object error) =>
          debugPrint('muscle recovery watch failed: $error'),
    );
    await _mapService.load();
    _mapLoaded = true;
    notifyListeners();
  }

  void _apply(MuscleRecoverySnapshot snapshot) {
    _hasSnapshot = true;
    _items = snapshot.items;
    _lastWorkoutAt = snapshot.lastWorkoutAt;
    _itemsByGroup
      ..clear()
      ..addEntries(_items.map((item) => MapEntry(item.group, item)));
    if (_selectedGroup == null || _itemsByGroup[_selectedGroup] == null) {
      _selectDefault();
    }
    notifyListeners();
  }

  static String _plural(int value, String unit) =>
      '$value ${value == 1 ? unit : '${unit}s'}';

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
