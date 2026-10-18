import 'package:floww/core/calisthenics/models/cal_slot.dart';

class CalSession {
  const CalSession({
    required this.name,
    required this.day,
    required this.focus,
    required this.goal,
    required this.slots,
    this.isSkillDay = false,
  });

  final String name;
  final String day;
  final String focus;
  final String goal;
  final List<CalSlot> slots;
  final bool isSkillDay;

  int get workingSets {
    var total = 0;
    for (final slot in slots) {
      total += slot.sets;
    }
    return total;
  }
}
