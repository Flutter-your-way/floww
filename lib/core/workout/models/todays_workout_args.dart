class TodaysWorkoutArgs {
  const TodaysWorkoutArgs({required this.date, this.catchUpFrom});

  final DateTime date;
  final DateTime? catchUpFrom;
}
