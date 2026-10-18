import 'package:floww/core/yoga/models/yoga_caution.dart';
import 'package:floww/core/yoga/models/yoga_prop.dart';

class YogaProfile {
  const YogaProfile({
    this.cautions = const {},
    this.ownedProps = const {},
    this.startWeek = 1,
  });

  static const YogaProfile standard = YogaProfile();

  final Set<YogaCaution> cautions;
  final Set<String> ownedProps;
  final int startWeek;

  bool owns(YogaProp prop) => prop.isOwnedIn(ownedProps);
}
