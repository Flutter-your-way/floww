import 'package:floww/core/workout/models/workout_section_kind.dart';

enum YogaClassSection {
  arrival(
    'arrival',
    'Arrival',
    0,
    3,
    WorkoutSectionKind.warmUp,
    'Comfortable seated position; observe natural breathing and set an '
        'intention.',
  ),
  warmUp(
    'warm-up',
    'Warm-up',
    3,
    8,
    WorkoutSectionKind.warmUp,
    'Neck turns within comfort, shoulder rolls, wrist/ankle circles, seated '
        'side bends, gentle Cat–Cow or seated spinal movement.',
  ),
  suryaNamaskar(
    'surya-namaskar',
    'Surya Namaskar',
    8,
    15,
    WorkoutSectionKind.warmUp,
    'Practise slow, modified rounds, pausing as needed. Omit any step that '
        'causes discomfort.',
  ),
  standing(
    'standing',
    'Standing',
    15,
    23,
    WorkoutSectionKind.main,
    'Tadasana, gentle side stretch, supported Vrksasana and Warrior II with a '
        'short stance if knees feel comfortable.',
  ),
  kneeling(
    'kneeling',
    'Kneeling / tabletop',
    23,
    29,
    WorkoutSectionKind.main,
    'Cat–Cow, Bird Dog one limb at a time if comfortable, Balasana variation '
        'or tabletop rest. Skip kneeling if it irritates the knees.',
  ),
  seated(
    'seated',
    'Seated',
    29,
    34,
    WorkoutSectionKind.main,
    'Dandasana, Baddha Konasana, gentle seated twist and Paschimottanasana '
        'with knees bent and a strap if needed.',
  ),
  supine(
    'supine',
    'Supine',
    34,
    37,
    WorkoutSectionKind.coolDown,
    'Apanasana, gentle supine twist and Setu Bandha low Bridge or pelvic '
        'tilts.',
  ),
  relaxation(
    'relaxation',
    'Relaxation',
    37,
    40,
    WorkoutSectionKind.coolDown,
    'Savasana or side-lying relaxation; finish with a gradual return to '
        'sitting.',
  );

  const YogaClassSection(
    this.id,
    this.title,
    this.startMinute,
    this.endMinute,
    this.workoutSection,
    this.sequence,
  );

  static const String _separator = '~';

  final String id;
  final String title;
  final int startMinute;
  final int endMinute;
  final WorkoutSectionKind workoutSection;
  final String sequence;

  int get minutes => endMinute - startMinute;

  String get rangeLabel => '$startMinute–$endMinute min';

  String entryIdFor(String postureId, int index) =>
      '$id$_separator$postureId$_separator$index';

  static YogaClassSection? ofEntryId(String entryId) {
    final parts = entryId.split(_separator);
    if (parts.length != 3) return null;
    for (final section in values) {
      if (section.id == parts.first) return section;
    }
    return null;
  }
}
