import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/workout/models/workout_shift_offer.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';

class WorkoutShiftService {
  WorkoutShiftService(this._planService);

  final WorkoutPlanService _planService;

  Future<WorkoutShiftOffer?> offerFor({
    required DateTime date,
    required ActiveProgramEntry? activeProgram,
    required List<WorkoutSessionEntity> sessions,
    required WorkoutPlanEntity? todayPlan,
    bool includePostpone = true,
  }) async {
    final today = AppDateUtils.dateOnly(DateTime.now());
    if (activeProgram == null || !AppDateUtils.isSameDay(date, today)) {
      return null;
    }
    final hasTodaySession = _hasSessionFor(sessions, today);

    if (todayPlan == null && !hasTodaySession) {
      final postponed = await _planService.postponedPlanOf(today);
      if (postponed != null) {
        return WorkoutShiftOffer(
          kind: WorkoutShiftKind.restore,
          plan: postponed,
        );
      }
    }

    final yesterday = AppDateUtils.addDays(today, -1);
    if (!_hasSessionFor(sessions, yesterday)) {
      final missed = await _planService.loadPlan(yesterday);
      if (missed != null &&
          missed.sessionId == null &&
          !missed.isScheduledFor(today) &&
          missed.programId == activeProgram.id) {
        return WorkoutShiftOffer(kind: WorkoutShiftKind.catchUp, plan: missed);
      }
    }

    if (includePostpone &&
        !hasTodaySession &&
        todayPlan != null &&
        todayPlan.sessionId == null) {
      return WorkoutShiftOffer(
        kind: WorkoutShiftKind.postpone,
        plan: todayPlan,
      );
    }
    return null;
  }

  Future<void> apply(
    WorkoutShiftOffer offer,
    ActiveProgramEntry activeProgram,
  ) async {
    final today = AppDateUtils.dateOnly(DateTime.now());
    switch (offer.kind) {
      case WorkoutShiftKind.restore:
        await _planService.restoreToToday(
          today: today,
          restored: activeProgram.shiftedBy(-1),
          postponed: offer.plan,
        );
      case WorkoutShiftKind.catchUp:
        await _planService.scheduleCatchUp(offer.plan, today);
      case WorkoutShiftKind.postpone:
        await _planService.shiftToToday(
          today: today,
          shifted: activeProgram.shiftedBy(1),
        );
    }
  }

  static bool _hasSessionFor(
    List<WorkoutSessionEntity> sessions,
    DateTime date,
  ) => sessions.any(
    (session) =>
        AppDateUtils.isSameDay(session.scheduledDate, date) &&
        (session.isCompleted || session.isInProgress),
  );
}
