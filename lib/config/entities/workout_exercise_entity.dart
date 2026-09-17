import 'package:floww/core/workout/models/exercise.dart';

class ExerciseCueEntry {
  const ExerciseCueEntry({required this.text, this.label});

  factory ExerciseCueEntry.fromJson(Map<String, dynamic> json) =>
      ExerciseCueEntry(
        text: json['text'] as String? ?? '',
        label: json['label'] as String?,
      );

  final String text;
  final String? label;

  Map<String, dynamic> toJson() => {
    'text': text,
    if (label != null) 'label': label,
  };
}

class ExerciseCatalogEntry {
  const ExerciseCatalogEntry({
    required this.id,
    required this.name,
    required this.group,
    required this.equipment,
    required this.met,
    required this.muscleShares,
    required this.defaultSets,
    required this.defaultReps,
    required this.defaultRestSeconds,
    required this.defaultRepsInReserve,
    this.defaultWeightKg,
    this.imageUrl,
    this.mistakes = const [],
    this.guidelines = const [],
    this.equipmentItems = const [],
    this.isCustom = false,
    this.isAdded = false,
  });

  factory ExerciseCatalogEntry.fromJson(Map<String, dynamic> json) =>
      ExerciseCatalogEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        group: _groupOf(json['muscleGroup'] as String?),
        equipment: _equipmentOf(json['equipment'] as String?),
        met: (json['met'] as num? ?? _fallbackMet).toDouble(),
        muscleShares: sharesOf(json['muscleShares']),
        defaultSets: (json['defaultSets'] as num? ?? 3).toInt(),
        defaultReps: (json['defaultReps'] as num? ?? 10).toInt(),
        defaultRestSeconds: (json['defaultRestSeconds'] as num? ?? 60).toInt(),
        defaultRepsInReserve: (json['defaultRepsInReserve'] as num? ?? 2)
            .toInt(),
        defaultWeightKg: (json['defaultWeightKg'] as num?)?.toDouble(),
        imageUrl: json['imageUrl'] as String?,
        mistakes: cuesOf(json['mistakes']),
        guidelines: cuesOf(json['guidelines']),
        equipmentItems: cuesOf(json['equipmentItems']),
        isCustom: json['isCustom'] as bool? ?? false,
        isAdded: json['isAdded'] as bool? ?? false,
      );

  static const double _fallbackMet = 5;

  final String id;
  final String name;
  final MuscleGroup group;
  final Equipment equipment;
  final double met;
  final Map<String, double> muscleShares;
  final int defaultSets;
  final int defaultReps;
  final int defaultRestSeconds;
  final int defaultRepsInReserve;
  final double? defaultWeightKg;
  final String? imageUrl;
  final List<ExerciseCueEntry> mistakes;
  final List<ExerciseCueEntry> guidelines;
  final List<ExerciseCueEntry> equipmentItems;
  final bool isCustom;
  final bool isAdded;

  bool get isBodyweight => equipment == Equipment.bodyweight;

  ExerciseCatalogEntry copyWith({bool? isAdded}) => ExerciseCatalogEntry(
    id: id,
    name: name,
    group: group,
    equipment: equipment,
    met: met,
    muscleShares: muscleShares,
    defaultSets: defaultSets,
    defaultReps: defaultReps,
    defaultRestSeconds: defaultRestSeconds,
    defaultRepsInReserve: defaultRepsInReserve,
    defaultWeightKg: defaultWeightKg,
    imageUrl: imageUrl,
    mistakes: mistakes,
    guidelines: guidelines,
    equipmentItems: equipmentItems,
    isCustom: isCustom,
    isAdded: isAdded ?? this.isAdded,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'muscleGroup': group.name,
    'equipment': equipment.name,
    'met': met,
    'muscleShares': muscleShares,
    'defaultSets': defaultSets,
    'defaultReps': defaultReps,
    'defaultRestSeconds': defaultRestSeconds,
    'defaultRepsInReserve': defaultRepsInReserve,
    if (defaultWeightKg != null) 'defaultWeightKg': defaultWeightKg,
    if (imageUrl != null) 'imageUrl': imageUrl,
    'mistakes': [for (final cue in mistakes) cue.toJson()],
    'guidelines': [for (final cue in guidelines) cue.toJson()],
    'equipmentItems': [for (final cue in equipmentItems) cue.toJson()],
    'isCustom': isCustom,
    'isAdded': isAdded,
  };

  Map<String, dynamic> toCatalogJson() {
    final json = toJson();
    json.remove('isAdded');
    return json;
  }

  static MuscleGroup _groupOf(String? value) => MuscleGroup.values.firstWhere(
    (group) => group.name == value,
    orElse: () => MuscleGroup.other,
  );

  static Equipment _equipmentOf(String? value) => Equipment.values.firstWhere(
    (equipment) => equipment.name == value,
    orElse: () => Equipment.bodyweight,
  );

  static Map<String, double> sharesOf(Object? value) {
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries)
        if (entry.value is num)
          '${entry.key}': (entry.value as num).toDouble(),
    };
  }

  static List<ExerciseCueEntry> cuesOf(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map<String, dynamic>) ExerciseCueEntry.fromJson(item),
    ];
  }
}
