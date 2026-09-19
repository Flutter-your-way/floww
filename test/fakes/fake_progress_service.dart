import 'dart:async';

import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/entities/progress_state_entity.dart';
import 'package:floww/config/entities/weight_log_entity.dart';
import 'package:floww/config/entities/workout_session_log_entity.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/progress/services/progress_service.dart';

class FakeProgressService implements ProgressService {
  FakeProgressService({
    ProgressRecords records = ProgressRecords.empty,
    this.userId = 'user-1',
    this.addWeightError,
  }) {
    _records = records;
  }

  @override
  final String? userId;

  final ProgressException? addWeightError;

  final List<DailyFlowEntry> savedFlow = [];
  final List<ProgressState> savedStates = [];

  late ProgressRecords _records;
  final StreamController<ProgressRecords> _controller =
      StreamController<ProgressRecords>.broadcast();
  int _nextId = 0;

  @override
  Stream<ProgressRecords> watchRecords() async* {
    yield _records;
    yield* _controller.stream;
  }

  @override
  Stream<List<DailyFlowEntry>> watchDailyFlow(DateTime from) async* {
    yield _records.storedFlow;
    yield* _controller.stream.map((records) => records.storedFlow);
  }

  void emit(ProgressRecords records) {
    _records = records;
    _controller.add(records);
  }

  @override
  Future<void> addWeightLog(double weightKg, DateTime loggedAt) async {
    final error = addWeightError;
    if (error != null) throw error;
    emit(
      _copyWith(
        weights: [
          ..._records.weights,
          WeightLog(
            id: 'weight-${++_nextId}',
            weightKg: weightKg,
            loggedAt: loggedAt,
          ),
        ],
      ),
    );
  }

  @override
  Future<void> deleteWeightLog(String id) async {
    emit(
      _copyWith(
        weights: [
          for (final log in _records.weights)
            if (log.id != id) log,
        ],
      ),
    );
  }

  @override
  Future<void> saveDailyFlow(List<DailyFlowEntry> entries) async {
    savedFlow.addAll(entries);
  }

  @override
  Future<void> saveState(ProgressState state) async {
    savedStates.add(state);
    emit(_copyWith(state: state));
  }

  ProgressRecords _copyWith({
    List<WeightLog>? weights,
    List<WorkoutSessionLog>? sessions,
    List<HabitDayLog>? habitDays,
    List<DailyFlowEntry>? storedFlow,
    NutritionLogs? nutrition,
    ProgressState? state,
    ProgressGoals? goals,
  }) => ProgressRecords(
    weights: weights ?? _records.weights,
    sessions: sessions ?? _records.sessions,
    habitDays: habitDays ?? _records.habitDays,
    storedFlow: storedFlow ?? _records.storedFlow,
    nutrition: nutrition ?? _records.nutrition,
    state: state ?? _records.state,
    goals: goals ?? _records.goals,
  );
}
