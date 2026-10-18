import 'package:floww/core/yoga/data/yoga_postures_data.dart';
import 'package:floww/core/yoga/models/surya_namaskar_step.dart';
import 'package:floww/core/yoga/models/yoga_caution.dart';
import 'package:floww/core/yoga/models/yoga_class_section.dart';
import 'package:floww/core/yoga/models/yoga_course_week.dart';

class YogaPillar {
  const YogaPillar({required this.name, required this.meaning});

  final String name;
  final String meaning;
}

class YogaModuleData {
  YogaModuleData._();

  static const String courseId = 'hatha-beginner';
  static const String programId = 'nyasp-hatha-foundations';
  static const String brand = 'NYASP';
  static const String brandLong = "Neha's Yoga Aatman Sattva Prana";
  static const String title = 'Hatha Yoga — Beginner';
  static const String subtitle =
      'Expanded asana library • Surya Namaskar • 35–45 minute class';
  static const String motto =
      'Move with steadiness. Breathe without force. Honour your limits.';
  static const int classMinutes = 40;
  static const int shortClassMinutes = 35;
  static const int longClassMinutes = 45;

  static const List<YogaPillar> pillars = [
    YogaPillar(name: 'Aatman', meaning: 'inner awareness'),
    YogaPillar(name: 'Sattva', meaning: 'clarity and balance'),
    YogaPillar(name: 'Prana', meaning: 'breath and vitality'),
  ];

  static const List<String> learningGoals = [
    'Learn a wider range of standing, seated, kneeling and supine postures.',
    'Practise a gentle, modified Surya Namaskar sequence with clear '
        'transition options.',
    'Build a balanced class with arrival, warm-up, asana, breath awareness '
        'and relaxation.',
    'Use props and modifications rather than forcing range of motion.',
  ];

  static const List<String> safetyEssentials = [
    'Practise on a stable, non-slip surface.',
    'Keep the breath comfortable and movements controlled.',
    'Stop for sharp pain, dizziness, chest pain, unusual breathlessness, '
        'numbness or feeling faint.',
    'Avoid forcing knees, hips, spine, wrists or shoulders.',
    'Active shoulder pain or injury is a reason to skip Surya Namaskar and '
        'weight-bearing poses such as Plank, Chaturanga and Downward-Facing '
        'Dog until appropriately assessed and pain-free.',
    'For knee discomfort, avoid deep knee flexion and lunging; use padding '
        'and alternatives.',
    'Pregnancy, recent surgery, injury or significant health conditions may '
        'require individual advice.',
  ];

  static const Map<YogaCaution, String> cautionNotes = {
    YogaCaution.shoulder:
        'Shoulder: WAVE replaces Surya Namaskar with the standing arm-and-'
        'spine warm-up and skips weight-bearing on the arms.',
    YogaCaution.knee:
        'Knee: kneeling is replaced with seated alternatives and standing '
        'poses avoid deep knee bends.',
    YogaCaution.wrist:
        'Wrist: tabletop poses are replaced with seated alternatives.',
    YogaCaution.back:
        'Back: Low Cobra and Bridge are swapped for gentler options.',
    YogaCaution.neck:
        'Neck: keep neck turns within comfort; Bridge becomes pelvic tilts.',
  };

  static const String disclaimer =
      'This guide is educational and is not a substitute for medical advice, '
      'personalised instruction or a teacher-training qualification.';

  static const String publicationNote =
      'Asana names and variations differ between yoga traditions. This module '
      'is a learning resource, not a certification syllabus, and should be '
      'reviewed by a qualified yoga teacher.';

  static const String teachingNote =
      'For a 35-minute class, Surya Namaskar is reduced to 2 rounds with '
      'shorter holds. For a 45-minute class, relaxation and transitions are '
      'extended rather than adding intensity.';

  static const String suryaIntro =
      'Surya Namaskar (Sun Salutation) links movement and breath. This '
      'beginner variation reduces loading and avoids a deep lunge. It is not '
      'suitable for everyone, especially people with active wrist, shoulder, '
      'back or knee symptoms.';

  static const List<String> suryaPacing = [
    'Start with 2 slow rounds, resting between rounds.',
    'Coordinate movement with an easy breath, but never hold the breath to '
        'keep up.',
    'A round can be shortened or replaced by the standing arm-and-spine '
        'warm-up.',
    'Avoid using this sequence as a fitness challenge.',
  ];

  static const List<SuryaNamaskarStep> suryaSteps = [
    SuryaNamaskarStep(
      number: 1,
      name: 'Prayer Pose',
      sanskritName: 'Pranamasana',
      instruction:
          'Stand tall in Tadasana, hands at the chest. Breathe naturally.',
    ),
    SuryaNamaskarStep(
      number: 2,
      name: 'Raised Arms',
      sanskritName: 'Hasta Uttanasana',
      instruction:
          'Inhale and raise arms only within a pain-free range. Do not force '
          'an overhead reach; hands may stay at the chest.',
    ),
    SuryaNamaskarStep(
      number: 3,
      name: 'Forward Fold',
      sanskritName: 'Uttanasana',
      instruction:
          'Exhale and hinge at the hips with knees bent. Hands rest on '
          'thighs, blocks or a chair; avoid pulling on the spine.',
    ),
    SuryaNamaskarStep(
      number: 4,
      name: 'Half Lift',
      sanskritName: 'Ardha Uttanasana',
      instruction:
          'Inhale, lengthen the spine and place hands on shins or blocks. '
          'Keep the neck long.',
    ),
    SuryaNamaskarStep(
      number: 5,
      name: 'Supported transition',
      instruction:
          'Exhale, bend the knees and bring hands to a chair or wall. Step '
          'back only if comfortable; for a knee- or shoulder-friendly option, '
          'return to standing instead.',
    ),
    SuryaNamaskarStep(
      number: 6,
      name: 'Optional tabletop',
      instruction:
          'If wrists, shoulders and knees are comfortable, lower to hands and '
          'knees with padding. Skip this step if kneeling or loading the arms '
          'hurts.',
      isOptional: true,
      cautions: {YogaCaution.knee, YogaCaution.wrist, YogaCaution.shoulder},
    ),
    SuryaNamaskarStep(
      number: 7,
      name: 'Gentle prone rest / low Cobra',
      instruction:
          'If comfortable, lie on the belly and lift the chest a little with '
          'elbows bent. Omit if there is shoulder or back discomfort.',
      isOptional: true,
      cautions: {
        YogaCaution.knee,
        YogaCaution.wrist,
        YogaCaution.shoulder,
        YogaCaution.back,
      },
    ),
    SuryaNamaskarStep(
      number: 8,
      name: 'Return to standing',
      instruction:
          'Move back through tabletop or use the chair/wall support to return '
          'to a bent-knee forward fold, then slowly rise.',
    ),
    SuryaNamaskarStep(
      number: 9,
      name: 'Raised Arms variation',
      sanskritName: 'Hasta Uttanasana',
      instruction:
          'Inhale and lift the arms only as far as comfortable, or keep hands '
          'at the chest.',
    ),
    SuryaNamaskarStep(
      number: 10,
      name: 'Prayer Pose',
      sanskritName: 'Pranamasana',
      instruction:
          'Exhale, return hands to the chest and pause. This completes one '
          'adapted round.',
    ),
  ];

  static const List<YogaCourseWeek> weeks = [
    YogaCourseWeek(
      number: 1,
      title: 'Familiarity',
      summary:
          'Tadasana, Sukhasana, seated mobility, Cat–Cow or seated '
          'alternative, Apanasana and Savasana. Learn safe transitions.',
      sections: {
        YogaClassSection.arrival: [YogaPosturesData.breathAwarenessId],
        YogaClassSection.warmUp: [
          'neck-turns',
          'shoulder-rolls',
          'wrist-ankle-circles',
          'seated-side-bend',
        ],
        YogaClassSection.standing: ['tadasana'],
        YogaClassSection.kneeling: ['cat-cow'],
        YogaClassSection.seated: ['sukhasana'],
        YogaClassSection.supine: ['apanasana'],
        YogaClassSection.relaxation: [YogaPosturesData.savasanaId],
      },
    ),
    YogaCourseWeek(
      number: 2,
      title: 'Mobility',
      summary:
          'Add supported Triangle, Tree Pose, Baddha Konasana, gentle seated '
          'twist and supine twist.',
      sections: {
        YogaClassSection.arrival: [YogaPosturesData.breathAwarenessId],
        YogaClassSection.warmUp: [
          'neck-turns',
          'shoulder-rolls',
          'wrist-ankle-circles',
          'seated-side-bend',
        ],
        YogaClassSection.standing: ['tadasana', 'tree-pose', 'trikonasana'],
        YogaClassSection.kneeling: ['cat-cow'],
        YogaClassSection.seated: [
          'sukhasana',
          'baddha-konasana',
          'bharadvajasana',
        ],
        YogaClassSection.supine: ['apanasana', 'supta-matsyendrasana'],
        YogaClassSection.relaxation: [YogaPosturesData.savasanaId],
      },
    ),
    YogaCourseWeek(
      number: 3,
      title: 'Gentle strength and flow',
      summary:
          'Introduce 2 rounds of modified Surya Namaskar, low Bridge and '
          'optional Bird Dog if pain-free.',
      suryaRounds: 2,
      sections: {
        YogaClassSection.arrival: [YogaPosturesData.breathAwarenessId],
        YogaClassSection.warmUp: [
          'neck-turns',
          'shoulder-rolls',
          'wrist-ankle-circles',
          'seated-cat-cow',
        ],
        YogaClassSection.suryaNamaskar: [YogaPosturesData.suryaNamaskarId],
        YogaClassSection.standing: ['tadasana', 'tree-pose', 'trikonasana'],
        YogaClassSection.kneeling: ['cat-cow', 'bird-dog'],
        YogaClassSection.seated: ['baddha-konasana', 'bharadvajasana'],
        YogaClassSection.supine: [
          'apanasana',
          'supta-matsyendrasana',
          'setu-bandha',
        ],
        YogaClassSection.relaxation: [YogaPosturesData.savasanaId],
      },
    ),
    YogaCourseWeek(
      number: 4,
      title: 'Build a complete class',
      summary:
          'Practise the 35–45 minute class with modifications and longer '
          'relaxation. Progress only when breathing and movement remain '
          'comfortable.',
      suryaRounds: 3,
      sections: {
        YogaClassSection.arrival: [YogaPosturesData.breathAwarenessId],
        YogaClassSection.warmUp: [
          'neck-turns',
          'shoulder-rolls',
          'wrist-ankle-circles',
          'seated-side-bend',
          'seated-cat-cow',
        ],
        YogaClassSection.suryaNamaskar: [YogaPosturesData.suryaNamaskarId],
        YogaClassSection.standing: [
          'tadasana',
          'parsva-tadasana',
          'tree-pose',
          'warrior-two',
        ],
        YogaClassSection.kneeling: ['cat-cow', 'bird-dog', 'childs-pose'],
        YogaClassSection.seated: [
          'dandasana',
          'baddha-konasana',
          'bharadvajasana',
          'paschimottanasana',
        ],
        YogaClassSection.supine: [
          'apanasana',
          'supta-matsyendrasana',
          'setu-bandha',
        ],
        YogaClassSection.relaxation: [YogaPosturesData.savasanaId],
      },
    ),
  ];

  static const List<String> selfCheckStatements = [
    'I could breathe comfortably.',
    'I knew when to modify or stop.',
    'I entered and left poses slowly.',
    'I used support when needed.',
    'I finished feeling settled rather than strained.',
  ];

  static const List<String> reflectionQuestions = [
    'What felt steady?',
    'Where did I need a modification?',
    'Did I breathe comfortably throughout?',
  ];

  static const int selfCheckMin = 1;
  static const int selfCheckMax = 5;
  static const String selfCheckMinLabel = 'Not yet';
  static const String selfCheckMaxLabel = 'Comfortable';

  static YogaCourseWeek weekAt(int number) {
    final index = (number - 1).clamp(0, weeks.length - 1);
    return weeks[index];
  }

  static int startWeekFor(String experienceLevel) =>
      switch (experienceLevel.trim().toLowerCase()) {
        'intermediate' => 2,
        'advanced' => 3,
        _ => 1,
      };
}
