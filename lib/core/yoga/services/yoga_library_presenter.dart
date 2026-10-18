import 'package:floww/core/yoga/data/yoga_module_data.dart';
import 'package:floww/core/yoga/data/yoga_postures_data.dart';
import 'package:floww/core/yoga/models/yoga_course_view_data.dart';
import 'package:floww/core/yoga/models/yoga_family.dart';
import 'package:floww/core/yoga/models/yoga_profile.dart';

class YogaLibraryPresenter {
  YogaLibraryPresenter._();

  static List<YogaFamilyItem> familiesOf(YogaProfile profile) => [
    for (final family in YogaFamily.values)
      YogaFamilyItem(
        title: family.title,
        intro: family.intro,
        postures: [
          for (final posture in YogaPosturesData.ofFamily(family))
            if (posture.id != YogaPosturesData.suryaNamaskarId)
              YogaPostureRowItem(
                id: posture.id,
                name: posture.name,
                sanskritName: posture.sanskritName,
                imageUrl: posture.imageUrl,
                isCautioned: posture.isCautionedFor(profile.cautions),
              ),
        ],
      ),
  ];

  static List<YogaTimelineItem> suryaStepsOf(YogaProfile profile) => [
    for (final step in YogaModuleData.suryaSteps)
      YogaTimelineItem(
        range: '${step.number}',
        title: step.isSkippedFor(profile.cautions)
            ? '${step.title} · skipped for you'
            : step.title,
        detail: step.instruction,
      ),
  ];
}
