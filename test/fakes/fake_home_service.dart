import 'dart:async';

import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/home/services/home_service.dart';

class FakeHomeService implements HomeService {
  FakeHomeService([this._records = HomeRecords.empty]);

  final List<DailyFlowEntry> savedFlow = [];
  final List<List<Habit>> savedHabitDays = [];

  HomeRecords _records;
  final StreamController<HomeRecords> _controller =
      StreamController<HomeRecords>.broadcast();

  @override
  Stream<HomeRecords> watchRecords(DateTime date) async* {
    yield _records;
    yield* _controller.stream;
  }

  @override
  Future<void> saveDailyFlow(DailyFlowEntry entry) async {
    savedFlow.add(entry);
  }

  @override
  Future<void> saveHabitDay(DateTime date, List<Habit> habits) async {
    savedHabitDays.add(habits);
  }

  void emit(HomeRecords records) {
    _records = records;
    _controller.add(records);
  }

  void dispose() => _controller.close();
}
