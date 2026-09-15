class AddExerciseSectionOption {
  const AddExerciseSectionOption({
    required this.id,
    required this.glyph,
    required this.title,
  });

  final String id;
  final String glyph;
  final String title;

  String get label => '$glyph $title';
}

class AddExercisePickerItem {
  const AddExercisePickerItem({
    required this.id,
    required this.name,
    required this.detailLabel,
    required this.isCustom,
    required this.isSelected,
  });

  final String id;
  final String name;
  final String detailLabel;
  final bool isCustom;
  final bool isSelected;
}

class AddExerciseTargetItem {
  const AddExerciseTargetItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.canDecrease,
    required this.canIncrease,
  });

  final String label;
  final String value;
  final String unit;
  final bool canDecrease;
  final bool canIncrease;
}
