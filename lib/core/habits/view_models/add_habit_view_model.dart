import 'package:flutter/foundation.dart';

import 'package:floww/core/habits/models/habit_suggestion.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/view_models/habit_labels.dart';

class AddHabitViewModel extends ChangeNotifier {
  AddHabitViewModel({
    required List<HabitSuggestion> suggestions,
    required List<HabitSuggestionGroup> groups,
  }) : _suggestions = suggestions,
       _groups = [
         for (final group in groups)
           if (group.suggestionIds.any(
             (id) => suggestions.any((suggestion) => suggestion.id == id),
           ))
             group,
       ];

  final List<HabitSuggestion> _suggestions;
  final List<HabitSuggestionGroup> _groups;

  int _groupIndex = 0;

  String get title => 'Add a Habit';

  String get subtitle => 'Choose from suggested or create your own';

  String get waveLabel => 'WAVE suggests';

  String get tryAnotherLabel => 'Try another';

  String get createCustomLabel => 'Create Custom Habit';

  String get emptyMessage => 'You have added every suggested habit.';

  bool get hasSuggestionGroup => _groups.isNotEmpty;

  bool get canTryAnother => _groups.length > 1;

  String get groupTitle => hasSuggestionGroup ? _groups[_groupIndex].title : '';

  List<HabitSuggestionItem> get groupItems {
    if (!hasSuggestionGroup) return const [];
    return [
      for (final id in _groups[_groupIndex].suggestionIds)
        if (_suggestionOf(id) case final suggestion?) _itemOf(suggestion),
    ];
  }

  List<HabitSuggestionItem> get suggestions => [
    for (final suggestion in _suggestions) _itemOf(suggestion),
  ];

  HabitSuggestion? suggestionOf(String id) => _suggestionOf(id);

  void nextGroup() {
    if (!canTryAnother) return;
    _groupIndex = (_groupIndex + 1) % _groups.length;
    notifyListeners();
  }

  HabitSuggestion? _suggestionOf(String id) =>
      _suggestions.where((suggestion) => suggestion.id == id).firstOrNull;

  HabitSuggestionItem _itemOf(HabitSuggestion suggestion) =>
      HabitSuggestionItem(
        id: suggestion.id,
        title: suggestion.title,
        targetLabel: HabitLabels.target(suggestion),
        icon: suggestion.icon,
      );
}
