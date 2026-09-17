import 'package:flutter/foundation.dart';

class MainTabController extends ChangeNotifier {
  MainTabController({int initialIndex = workoutTab}) : _index = initialIndex;

  static const int homeTab = 0;
  static const int nutritionTab = 1;
  static const int workoutTab = 2;
  static const int habitsTab = 3;
  static const int progressTab = 4;

  int _index;
  bool _shouldCreateHabit = false;

  int get index => _index;

  bool get shouldCreateHabit => _shouldCreateHabit;

  void select(int index) {
    if (_index == index) return;
    _index = index;
    notifyListeners();
  }

  void openHabitCreation() {
    _shouldCreateHabit = true;
    _index = habitsTab;
    notifyListeners();
  }

  void consumeHabitCreation() {
    if (!_shouldCreateHabit) return;
    _shouldCreateHabit = false;
  }
}
