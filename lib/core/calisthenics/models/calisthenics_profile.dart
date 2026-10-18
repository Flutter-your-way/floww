import 'package:floww/core/calisthenics/models/cal_gear.dart';

class CalisthenicsProfile {
  const CalisthenicsProfile({
    this.gear = const {},
    this.results = const {},
    this.bodyweightKg,
  });

  static const CalisthenicsProfile standard = CalisthenicsProfile();

  final Set<CalGear> gear;
  final Map<String, double> results;
  final double? bodyweightKg;

  bool owns(CalGear item) => gear.contains(item);
}
