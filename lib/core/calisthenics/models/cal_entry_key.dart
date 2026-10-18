import 'package:floww/core/calisthenics/data/calisthenics_program_data.dart';
import 'package:floww/core/calisthenics/models/cal_level.dart';
import 'package:floww/core/calisthenics/models/cal_slot.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';

enum CalEntryKind {
  warmUp('w', WorkoutSectionKind.warmUp),
  main('m', WorkoutSectionKind.main),
  coolDown('c', WorkoutSectionKind.coolDown);

  const CalEntryKind(this.code, this.section);

  final String code;
  final WorkoutSectionKind section;

  static CalEntryKind? fromCode(String code) {
    for (final kind in values) {
      if (kind.code == code) return kind;
    }
    return null;
  }
}

class CalEntryKey {
  const CalEntryKey({
    required this.level,
    required this.session,
    required this.kind,
    required this.index,
  });

  static final RegExp _pattern = RegExp(r'^cal(\d)-(\d+)-([wmc])(\d+)-');

  final CalLevel level;
  final int session;
  final CalEntryKind kind;
  final int index;

  String idFor(String moveId) =>
      'cal${level.number}-$session-${kind.code}$index-$moveId';

  static CalEntryKey? parse(String entryId) {
    final match = _pattern.firstMatch(entryId);
    if (match == null) return null;
    final kind = CalEntryKind.fromCode(match.group(3)!);
    if (kind == null) return null;
    return CalEntryKey(
      level: CalLevel.of(int.parse(match.group(1)!)),
      session: int.parse(match.group(2)!),
      kind: kind,
      index: int.parse(match.group(4)!),
    );
  }

  CalSlot? get slot {
    final slots = switch (kind) {
      CalEntryKind.warmUp => CalisthenicsProgramData.warmUp,
      CalEntryKind.coolDown => CalisthenicsProgramData.coolDown,
      CalEntryKind.main => _sessionSlots,
    };
    return index < slots.length ? slots[index] : null;
  }

  List<CalSlot> get _sessionSlots {
    final sessions = CalisthenicsProgramData.sessionsOf(level);
    return session < sessions.length ? sessions[session].slots : const [];
  }
}
