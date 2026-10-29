import 'package:floww/config/constants/app_images.dart';
import 'package:floww/core/yoga/models/yoga_caution.dart';
import 'package:floww/core/yoga/models/yoga_family.dart';
import 'package:floww/core/yoga/models/yoga_posture.dart';
import 'package:floww/core/yoga/models/yoga_prop.dart';

class YogaPosturesData {
  YogaPosturesData._();

  static const String suryaNamaskarId = 'sun-salutation';
  static const String breathAwarenessId = 'seated-meditation';
  static const String savasanaId = 'savasana';

  static final Map<String, YogaPosture> _byId = {
    for (final posture in all) posture.id: posture,
  };

  static YogaPosture? byId(String id) => _byId[id];

  static bool contains(String id) => _byId.containsKey(id);

  static List<YogaPosture> ofFamily(YogaFamily family) => [
    for (final posture in all)
      if (posture.family == family) posture,
  ];

  static const List<YogaPosture> all = [
    YogaPosture(
      id: breathAwarenessId,
      name: 'Breath Awareness',
      family: YogaFamily.warmUp,
      summary:
          'Sit or lie comfortably and observe natural breathing for 1–3 '
          'minutes. Do not force deep breaths, breath retention or forceful '
          'pranayama in this beginner sequence.',
      goal:
          'Arrive on the mat, notice the natural breath and set an intention.',
      entrySteps: [
        'Sit on a cushion or chair with the spine tall and shoulders soft.',
        'Rest the hands on the thighs and let the eyes close or soften.',
      ],
      exitSteps: [
        'Let the eyes open slowly and take in the room.',
        'Move the fingers and toes before changing position.',
      ],
      breathCues: [
        'Observe the natural breath without changing it.',
        'Never hold the breath or force a deep inhale.',
      ],
      alignmentCues: [
        'Sit tall without stiffening.',
        'Relax the jaw, face and shoulders.',
      ],
      avoid: ['Forcing long or deep breaths', 'Holding the breath'],
      modifications: [
        YogaModification('Sit on a chair with both feet grounded.'),
        YogaModification(
          'Sit on a chair rather than cross-legged on the floor.',
          caution: YogaCaution.knee,
        ),
        YogaModification(
          'Keep the head level and still; avoid dropping the chin.',
          caution: YogaCaution.neck,
        ),
      ],
      holdSeconds: 150,
      holdGuidance: 'Rest here for 1–3 minutes.',
      imageUrl: AppImages.seatedMeditation,
      props: [YogaProp.cushion, YogaProp.chair],
      met: 1.5,
      muscleShares: {'Core': 0.1},
    ),
    YogaPosture(
      id: 'neck-turns',
      name: 'Neck Turns',
      family: YogaFamily.warmUp,
      summary:
          'Slowly turn the head to look over one shoulder, then the other, '
          'staying within a comfortable range.',
      goal: 'Release tension in the neck before moving the whole body.',
      entrySteps: [
        'Sit tall with the shoulders relaxed.',
        'Turn the head slowly to one side, then return to centre.',
      ],
      exitSteps: ['Return the head to centre and pause for one breath.'],
      breathCues: ['Exhale as you turn, inhale as you return to centre.'],
      alignmentCues: ['Keep the chin level.', 'Move only within comfort.'],
      avoid: ['Rolling the head backward', 'Pushing into the end of range'],
      modifications: [
        YogaModification(
          'Make the turn very small, or keep the head still and simply '
          'breathe.',
          caution: YogaCaution.neck,
        ),
      ],
      holdSeconds: 40,
      holdGuidance: 'Three to five slow turns each way.',
      imageUrl: AppImages.yogaNeckTurns,
      props: [YogaProp.cushion],
      met: 1.8,
      muscleShares: {'Shoulders': 0.2},
    ),
    YogaPosture(
      id: 'shoulder-rolls',
      name: 'Shoulder Rolls',
      family: YogaFamily.warmUp,
      summary:
          'Lift the shoulders toward the ears, draw them back and let them '
          'soften down in slow circles.',
      goal: 'Warm the shoulders gently and relax the upper back.',
      entrySteps: [
        'Sit or stand tall with the arms relaxed.',
        'Circle the shoulders up, back and down.',
      ],
      exitSteps: ['Let the shoulders settle and the arms hang heavy.'],
      breathCues: ['Inhale to lift, exhale to roll back and down.'],
      alignmentCues: ['Keep the neck long.', 'Move slowly, without jerking.'],
      avoid: ['Hunching forward', 'Rushing the circles'],
      modifications: [
        YogaModification(
          'Make the circles small and stop if the shoulder clicks or aches.',
          caution: YogaCaution.shoulder,
        ),
      ],
      holdSeconds: 40,
      holdGuidance: 'Five slow circles back, then five forward.',
      imageUrl: AppImages.yogaShoulderRolls,
      props: [YogaProp.cushion],
      met: 1.8,
      muscleShares: {'Shoulders': 0.3, 'Back': 0.2},
    ),
    YogaPosture(
      id: 'wrist-ankle-circles',
      name: 'Wrist & Ankle Circles',
      family: YogaFamily.warmUp,
      summary:
          'Circle the wrists and ankles slowly in both directions to warm '
          'the small joints.',
      goal: 'Prepare the wrists and ankles for standing and tabletop work.',
      entrySteps: [
        'Sit comfortably and extend the legs or keep the knees bent.',
        'Circle the wrists, then the ankles, in both directions.',
      ],
      exitSteps: ['Shake the hands out gently and rest them on the thighs.'],
      breathCues: ['Keep the breath easy and steady.'],
      alignmentCues: ['Move through a smooth, pain-free circle.'],
      avoid: ['Forcing the end of range'],
      modifications: [
        YogaModification(
          'Make the wrist circles tiny, or simply open and close the hands.',
          caution: YogaCaution.wrist,
        ),
      ],
      holdSeconds: 45,
      holdGuidance: 'Five circles each direction for each joint.',
      imageUrl: AppImages.yogaWristAnkleCircles,
      props: [YogaProp.cushion],
      met: 1.8,
      muscleShares: {'Forearms': 0.2, 'Calves': 0.2},
    ),
    YogaPosture(
      id: 'standing-arm-spine',
      name: 'Standing Arm & Spine Warm-up',
      family: YogaFamily.warmUp,
      summary:
          'A standing alternative to Surya Namaskar: gentle arm movements '
          'and a small hip hinge without loading the arms.',
      goal: 'Link breath and movement without weight-bearing on the arms.',
      entrySteps: [
        'Stand in Tadasana with the knees soft.',
        'Sweep the arms forward to chest height, then lower them.',
        'Hinge slightly from the hips with hands on the thighs, then rise.',
      ],
      exitSteps: ['Return to Tadasana with the hands at the chest.'],
      breathCues: [
        'Inhale as the arms lift, exhale as they lower.',
        'Never hold the breath to keep up.',
      ],
      alignmentCues: [
        'Lift the arms only within a pain-free range.',
        'Keep the knees soft as you hinge.',
      ],
      avoid: ['Forcing an overhead reach', 'Rounding hard through the back'],
      modifications: [
        YogaModification(
          'Keep the hands at the chest and move only the spine.',
          caution: YogaCaution.shoulder,
        ),
        YogaModification('Hold a chair back for balance throughout.'),
      ],
      holdSeconds: 60,
      holdGuidance: 'Repeat slowly for about one minute per round.',
      imageUrl: AppImages.yogaStandingArmSpine,
      props: [YogaProp.mat, YogaProp.chair],
      met: 2.5,
      muscleShares: {'Shoulders': 0.3, 'Hamstrings': 0.3, 'Core': 0.2},
    ),
    YogaPosture(
      id: 'seated-cat-cow',
      name: 'Seated Cat–Cow',
      family: YogaFamily.warmUp,
      summary:
          'Seated alternative to Cat–Cow: hands on the knees, gently round '
          'and lift the spine without kneeling.',
      goal: 'Mobilise the spine without weight on the knees or wrists.',
      entrySteps: [
        'Sit tall on a cushion or chair with hands on the knees.',
        'Gently lift the chest, then round the back.',
      ],
      exitSteps: ['Return to a neutral, tall spine.'],
      breathCues: ['Inhale to lift the chest, exhale to round.'],
      alignmentCues: [
        'Keep the range small.',
        'Let the head follow the spine.',
      ],
      avoid: ['Forcing the arch', 'Dropping the head back'],
      modifications: [
        YogaModification(
          'Keep the head in line with the spine rather than lifting it.',
          caution: YogaCaution.neck,
        ),
      ],
      holdSeconds: 45,
      holdGuidance: 'Five to eight slow rounds.',
      imageUrl: AppImages.yogaSeatedCatCow,
      props: [YogaProp.cushion, YogaProp.chair],
      met: 2,
      muscleShares: {'Back': 0.4, 'Core': 0.3},
    ),
    YogaPosture(
      id: suryaNamaskarId,
      name: 'Sun Salutation',
      sanskritName: 'Surya Namaskar',
      family: YogaFamily.standing,
      summary:
          'A gentle beginner version that links movement and breath. It '
          'reduces loading and avoids a deep lunge. It is not suitable for '
          'everyone, especially people with active wrist, shoulder, back or '
          'knee symptoms.',
      goal: 'Coordinate slow movement with an easy breath.',
      entrySteps: [
        'Stand tall in Tadasana with hands at the chest.',
        'Follow the ten adapted steps, pausing whenever you need.',
      ],
      exitSteps: [
        'Finish in Pranamasana with hands at the chest and pause.',
        'Rest between rounds.',
      ],
      breathCues: [
        'Coordinate movement with an easy breath.',
        'Never hold the breath to keep up.',
      ],
      alignmentCues: [
        'Hinge at the hips with knees bent.',
        'Raise the arms only within a pain-free range.',
      ],
      avoid: [
        'Using the sequence as a fitness challenge',
        'Pulling on the spine in the forward fold',
      ],
      modifications: [
        YogaModification(
          'Skip the tabletop step and return to standing instead.',
          caution: YogaCaution.knee,
        ),
        YogaModification(
          'Skip the tabletop step to avoid loading the wrists.',
          caution: YogaCaution.wrist,
        ),
        YogaModification(
          'Skip low Cobra and keep the transition supported by a chair.',
          caution: YogaCaution.back,
        ),
        YogaModification(
          'Replace a round with the standing arm-and-spine warm-up.',
        ),
      ],
      holdSeconds: 90,
      holdGuidance: 'Start with 2 slow rounds, resting between rounds.',
      imageUrl: AppImages.sunSalutation,
      props: [YogaProp.mat, YogaProp.chair, YogaProp.blocks, YogaProp.blanket],
      cautions: {YogaCaution.shoulder},
      alternativeId: 'standing-arm-spine',
      met: 3,
      muscleShares: {'Hamstrings': 0.5, 'Shoulders': 0.4, 'Core': 0.4},
    ),
    YogaPosture(
      id: 'tadasana',
      name: 'Mountain Pose',
      sanskritName: 'Tadasana',
      family: YogaFamily.standing,
      summary:
          'Feet grounded, knees soft, spine tall and shoulders relaxed. Keep '
          'weight balanced across both feet.',
      goal: 'Find a steady, balanced foundation for every standing pose.',
      entrySteps: [
        'Stand with the feet hip-width apart.',
        'Soften the knees and lengthen up through the crown.',
      ],
      exitSteps: ['Shake out the legs gently if they feel tight.'],
      breathCues: ['Let the breath move naturally into the ribs.'],
      alignmentCues: [
        'Feet grounded, knees soft.',
        'Spine tall, shoulders relaxed.',
        'Weight balanced across both feet.',
      ],
      avoid: ['Locking the knees', 'Leaning into the heels or toes'],
      modifications: [
        YogaModification('Stand with your back near a wall for feedback.'),
      ],
      holdSeconds: 30,
      holdGuidance: 'Stand for 5–8 easy breaths.',
      imageUrl: AppImages.yogaTadasana,
      props: [YogaProp.mat, YogaProp.wall],
      met: 1.8,
      muscleShares: {'Core': 0.2, 'Calves': 0.2},
    ),
    YogaPosture(
      id: 'urdhva-hastasana',
      name: 'Upward Salute',
      sanskritName: 'Urdhva Hastasana',
      family: YogaFamily.standing,
      summary:
          'Raise arms only within a comfortable range; hands can remain at '
          'chest height if overhead movement is uncomfortable.',
      goal: 'Lengthen the side body with a pain-free arm lift.',
      entrySteps: [
        'Stand in Tadasana.',
        'Raise the arms slowly to a comfortable height.',
      ],
      exitSteps: ['Lower the arms slowly back to the sides.'],
      breathCues: ['Inhale as the arms lift, exhale as they lower.'],
      alignmentCues: [
        'Keep the shoulders away from the ears.',
        'Ribs soft, no arch through the lower back.',
      ],
      avoid: ['Forcing an overhead reach', 'Arching the lower back'],
      modifications: [
        YogaModification(
          'Keep the hands at chest height.',
          caution: YogaCaution.shoulder,
        ),
      ],
      holdSeconds: 20,
      holdGuidance: 'Hold for 3–5 breaths, or move with the breath.',
      imageUrl: AppImages.yogaUrdhvaHastasana,
      props: [YogaProp.mat],
      met: 2,
      muscleShares: {'Shoulders': 0.4, 'Core': 0.2},
    ),
    YogaPosture(
      id: 'parsva-tadasana',
      name: 'Standing Side Stretch',
      sanskritName: 'Parsva Tadasana',
      family: YogaFamily.standing,
      summary:
          'Reach one arm gently upward or keep hands on hips, then incline '
          'slightly to the side without twisting forward.',
      goal: 'Open the side body gently.',
      entrySteps: [
        'Stand in Tadasana and reach one arm up or place hands on hips.',
        'Incline slightly to the side.',
      ],
      exitSteps: ['Return to upright on an inhale and lower the arm.'],
      breathCues: ['Breathe into the stretched side of the ribs.'],
      alignmentCues: [
        'Keep both feet grounded.',
        'Lean sideways without twisting forward.',
      ],
      avoid: ['Collapsing into the lower side', 'Twisting the chest down'],
      modifications: [
        YogaModification(
          'Keep the hands on the hips instead of reaching up.',
          caution: YogaCaution.shoulder,
        ),
      ],
      holdSeconds: 20,
      holdGuidance: 'Hold for 3–5 breaths on each side.',
      imageUrl: AppImages.yogaParsvaTadasana,
      props: [YogaProp.mat],
      isPerSide: true,
      met: 2,
      muscleShares: {'Core': 0.4, 'Shoulders': 0.2},
    ),
    YogaPosture(
      id: 'tree-pose',
      name: 'Tree Pose',
      sanskritName: 'Vrksasana',
      family: YogaFamily.standing,
      summary:
          'Place toes of the lifted foot on the floor or foot at the '
          'ankle/calf, never directly against the knee. Hold a wall or chair.',
      goal: 'Build balance with support.',
      entrySteps: [
        'Stand beside a wall or chair and hold it lightly.',
        'Shift weight to one foot and place the other foot at the ankle, '
            'calf or with toes on the floor.',
      ],
      exitSteps: ['Lower the foot slowly and stand evenly on both feet.'],
      breathCues: ['Keep the breath slow; steady breath steadies balance.'],
      alignmentCues: [
        'Never press the foot directly against the knee.',
        'Keep the standing knee soft.',
      ],
      avoid: ['Placing the foot on the knee', 'Holding the breath to balance'],
      modifications: [
        YogaModification('Keep the toes of the lifted foot on the floor.'),
        YogaModification(
          'Keep both hands on the support and the foot low at the ankle.',
          caution: YogaCaution.knee,
        ),
      ],
      holdSeconds: 25,
      holdGuidance: 'Hold for 3–5 breaths on each side.',
      imageUrl: AppImages.treePose,
      props: [YogaProp.wall, YogaProp.chair],
      isPerSide: true,
      met: 2.5,
      muscleShares: {'Core': 0.5, 'Glutes': 0.4, 'Calves': 0.3},
    ),
    YogaPosture(
      id: 'warrior-two',
      name: 'Warrior II',
      sanskritName: 'Virabhadrasana II',
      family: YogaFamily.standing,
      summary:
          'Use a short stance and shallow knee bend. Keep the front knee '
          'comfortable and aligned with the foot. Skip if knee pain appears.',
      goal: 'Build gentle leg strength with an open, steady chest.',
      entrySteps: [
        'Step the feet a short distance apart, front toes forward.',
        'Bend the front knee a little and extend the arms if comfortable.',
      ],
      exitSteps: ['Straighten the front leg and step the feet together.'],
      breathCues: ['Breathe evenly; soften the face and shoulders.'],
      alignmentCues: [
        'Short stance, shallow knee bend.',
        'Front knee aligned with the foot.',
      ],
      avoid: ['Letting the knee drift past the toes', 'A deep lunge'],
      modifications: [
        YogaModification('Rest the hands on the hips instead of extending.'),
        YogaModification(
          'Keep the arms low or hands on hips.',
          caution: YogaCaution.shoulder,
        ),
      ],
      holdSeconds: 25,
      holdGuidance: 'Hold for 3–5 breaths on each side.',
      imageUrl: AppImages.warriorTwo,
      props: [YogaProp.mat, YogaProp.chair],
      cautions: {YogaCaution.knee},
      alternativeId: 'prasarita-padottanasana',
      isPerSide: true,
      met: 3,
      muscleShares: {'Quadriceps': 0.6, 'Glutes': 0.4, 'Shoulders': 0.3},
    ),
    YogaPosture(
      id: 'trikonasana',
      name: 'Triangle Pose',
      sanskritName: 'Trikonasana',
      family: YogaFamily.standing,
      summary:
          'Use a short stance, soften knees and rest the lower hand on a '
          'block or thigh. Avoid locking the knees or forcing a deep side '
          'bend.',
      goal: 'Lengthen the side body and legs with support.',
      entrySteps: [
        'Take a short stance with the front toes forward.',
        'Reach forward, then rest the lower hand on a block or thigh.',
      ],
      exitSteps: ['Press through the feet and rise on an inhale.'],
      breathCues: ['Breathe into the upper side of the ribs.'],
      alignmentCues: ['Soften both knees.', 'Lower hand on a block or thigh.'],
      avoid: ['Locking the knees', 'Forcing a deep side bend'],
      modifications: [
        YogaModification('Rest the upper hand on the hip.'),
        YogaModification(
          'Keep the gaze down or forward rather than up.',
          caution: YogaCaution.neck,
        ),
        YogaModification(
          'Keep the upper hand on the hip rather than reaching up.',
          caution: YogaCaution.shoulder,
        ),
      ],
      holdSeconds: 25,
      holdGuidance: 'Hold for 3–5 breaths on each side.',
      imageUrl: AppImages.yogaTrikonasana,
      props: [YogaProp.blocks, YogaProp.mat],
      isPerSide: true,
      met: 2.5,
      muscleShares: {'Hamstrings': 0.5, 'Core': 0.4, 'Glutes': 0.3},
    ),
    YogaPosture(
      id: 'prasarita-padottanasana',
      name: 'Wide-Legged Forward Fold',
      sanskritName: 'Prasarita Padottanasana',
      family: YogaFamily.standing,
      summary:
          'Stand with feet wide enough to feel stable, knees soft and hands '
          'on a chair or blocks. Keep the fold shallow.',
      goal: 'A stable, wide-legged posture without deep knee bending.',
      entrySteps: [
        'Step the feet wide enough to feel stable.',
        'Hinge forward a little with hands on a chair or blocks.',
      ],
      exitSteps: [
        'Bring hands to the hips, press through the feet and rise slowly.',
      ],
      breathCues: ['Exhale as you hinge, inhale as you rise.'],
      alignmentCues: ['Knees soft.', 'Keep the fold shallow.'],
      avoid: ['Folding deeply', 'Rising quickly'],
      modifications: [
        YogaModification('Keep the hands on a chair seat.'),
        YogaModification(
          'Keep the fold very small and rise slowly.',
          caution: YogaCaution.back,
        ),
      ],
      holdSeconds: 30,
      holdGuidance: 'Hold for 4–6 breaths.',
      imageUrl: AppImages.yogaPrasaritaPadottanasana,
      props: [YogaProp.chair, YogaProp.blocks],
      met: 2.2,
      muscleShares: {'Hamstrings': 0.6, 'Back': 0.2},
    ),
    YogaPosture(
      id: 'chair-pose',
      name: 'Chair Pose',
      sanskritName: 'Utkatasana',
      family: YogaFamily.standing,
      summary:
          'Bend the knees only a little and send hips back as if reaching for '
          'a chair. Use a real chair behind you; omit if knees are '
          'uncomfortable.',
      goal: 'Gentle leg strength in a shallow, supported squat.',
      entrySteps: [
        'Stand in front of a chair.',
        'Bend the knees a little and send the hips back.',
      ],
      exitSteps: ['Press through the feet and stand tall.'],
      breathCues: ['Breathe steadily; do not hold the breath.'],
      alignmentCues: [
        'Bend the knees only a little.',
        'Hips back as if reaching for a chair.',
      ],
      avoid: ['Sinking deep', 'Knees collapsing inward'],
      modifications: [
        YogaModification('Touch the chair seat lightly with the hips.'),
      ],
      holdSeconds: 20,
      holdGuidance: 'Hold for 3–4 breaths.',
      imageUrl: AppImages.chairPose,
      props: [YogaProp.chair],
      cautions: {YogaCaution.knee},
      isOptional: true,
      met: 3,
      muscleShares: {'Quadriceps': 0.8, 'Glutes': 0.5, 'Core': 0.3},
    ),
    YogaPosture(
      id: 'cat-cow',
      name: 'Cat–Cow',
      sanskritName: 'Marjaryasana–Bitilasana',
      family: YogaFamily.kneeling,
      summary:
          'From tabletop, move gently between rounding and extending the '
          'spine. Keep the range small and breath easy. Seated Cat–Cow is an '
          'alternative.',
      goal: 'Mobilise the whole spine gently.',
      entrySteps: [
        'Come to hands and knees with a blanket under the knees.',
        'Hands under shoulders, knees under hips.',
      ],
      exitSteps: ['Return to a neutral tabletop, then sit back to rest.'],
      breathCues: ['Inhale to lift the chest, exhale to round the back.'],
      alignmentCues: ['Keep the range small.', 'Breath easy.'],
      avoid: ['Forcing the arch', 'Locking the elbows'],
      modifications: [
        YogaModification('Practise seated Cat–Cow on a chair instead.'),
      ],
      holdSeconds: 45,
      holdGuidance: 'Five to eight slow rounds.',
      imageUrl: AppImages.catCow,
      props: [YogaProp.mat, YogaProp.blanket],
      cautions: {YogaCaution.knee, YogaCaution.wrist, YogaCaution.shoulder},
      alternativeId: 'seated-cat-cow',
      met: 2.5,
      muscleShares: {'Back': 0.4, 'Core': 0.3},
    ),
    YogaPosture(
      id: 'bird-dog',
      name: 'Bird Dog',
      family: YogaFamily.kneeling,
      summary:
          'From tabletop, extend one leg at a time or one arm at a time '
          'before combining. Keep hips level; avoid if wrists or shoulders '
          'are painful.',
      goal: 'Gentle core stability with steady breath.',
      entrySteps: [
        'Start in tabletop with a blanket under the knees.',
        'Extend one leg back along the floor, then lift it a little.',
      ],
      exitSteps: ['Return the limb to tabletop before switching sides.'],
      breathCues: ['Exhale as you extend, inhale as you return.'],
      alignmentCues: ['Keep hips level.', 'One limb at a time first.'],
      avoid: ['Twisting the hips', 'Arching the lower back'],
      modifications: [
        YogaModification('Extend only the leg, keeping both hands down.'),
        YogaModification(
          'Extend only the leg and keep the movement small.',
          caution: YogaCaution.back,
        ),
      ],
      holdSeconds: 20,
      holdGuidance: 'Three to five slow reaches on each side.',
      imageUrl: AppImages.yogaBirdDog,
      props: [YogaProp.mat, YogaProp.blanket],
      cautions: {YogaCaution.knee, YogaCaution.wrist, YogaCaution.shoulder},
      isPerSide: true,
      isOptional: true,
      met: 2.8,
      muscleShares: {'Core': 0.6, 'Glutes': 0.4, 'Back': 0.3},
    ),
    YogaPosture(
      id: 'childs-pose',
      name: "Child's Pose",
      sanskritName: 'Balasana',
      family: YogaFamily.kneeling,
      summary:
          'Move hips back only as far as comfortable and support the torso '
          'or head with cushions. Skip if knee or hip discomfort occurs.',
      goal: 'A supported resting shape between kneeling postures.',
      entrySteps: [
        'From tabletop, move the hips back only as far as comfortable.',
        'Rest the torso or head on cushions.',
      ],
      exitSteps: ['Walk the hands back and rise slowly to sitting.'],
      breathCues: ['Feel the breath move into the back of the ribs.'],
      alignmentCues: [
        'Support the torso or head with cushions.',
        'Knees as wide as comfortable.',
      ],
      avoid: ['Forcing the hips to the heels'],
      modifications: [YogaModification('Rest in tabletop instead.')],
      holdSeconds: 45,
      holdGuidance: 'Rest for 5–8 breaths.',
      imageUrl: AppImages.childsPose,
      props: [YogaProp.bolster, YogaProp.cushion, YogaProp.blanket],
      cautions: {YogaCaution.knee},
      alternativeId: 'makarasana',
      met: 1.8,
      muscleShares: {'Back': 0.3, 'Glutes': 0.3},
    ),
    YogaPosture(
      id: 'anahatasana',
      name: 'Puppy Pose',
      sanskritName: 'Anahatasana',
      family: YogaFamily.kneeling,
      summary:
          'From tabletop, walk hands forward only a little while keeping hips '
          'over knees. Avoid if shoulders feel strained; use seated side '
          'stretch instead.',
      goal: 'A gentle opening for the upper back and shoulders.',
      entrySteps: [
        'Start in tabletop.',
        'Walk the hands forward a little, keeping hips over knees.',
      ],
      exitSteps: ['Walk the hands back to tabletop.'],
      breathCues: ['Breathe softly into the upper back.'],
      alignmentCues: ['Hips stay over knees.', 'Walk forward only a little.'],
      avoid: ['Sinking the chest toward the floor', 'Straining the shoulders'],
      modifications: [YogaModification('Use a seated side stretch instead.')],
      holdSeconds: 25,
      holdGuidance: 'Hold for 3–5 breaths.',
      imageUrl: AppImages.yogaAnahatasana,
      props: [YogaProp.mat, YogaProp.blanket],
      cautions: {YogaCaution.shoulder, YogaCaution.wrist, YogaCaution.knee},
      alternativeId: 'seated-side-bend',
      isOptional: true,
      met: 2,
      muscleShares: {'Shoulders': 0.4, 'Back': 0.3},
    ),
    YogaPosture(
      id: 'vajrasana',
      name: 'Thunderbolt Pose',
      sanskritName: 'Vajrasana',
      family: YogaFamily.kneeling,
      summary:
          'Sit back toward heels only if knees and ankles tolerate it. A '
          'block between hips and heels can reduce the bend; otherwise sit '
          'on a chair.',
      goal: 'A steady kneeling seat for breath awareness.',
      entrySteps: [
        'Kneel with a blanket under the knees.',
        'Sit back toward the heels, using a block if needed.',
      ],
      exitSteps: ['Lean forward to tabletop before standing.'],
      breathCues: ['Breathe naturally with a tall spine.'],
      alignmentCues: ['Use a block between hips and heels.'],
      avoid: ['Forcing the hips down'],
      modifications: [YogaModification('Sit on a chair instead.')],
      holdSeconds: 45,
      holdGuidance: 'Sit for 5–8 breaths.',
      imageUrl: AppImages.yogaVajrasana,
      props: [YogaProp.blocks, YogaProp.blanket, YogaProp.chair],
      cautions: {YogaCaution.knee},
      alternativeId: 'sukhasana',
      isOptional: true,
      met: 1.5,
      muscleShares: {'Quadriceps': 0.2},
    ),
    YogaPosture(
      id: 'dandasana',
      name: 'Staff Pose',
      sanskritName: 'Dandasana',
      family: YogaFamily.seated,
      summary:
          'Sit on a folded blanket with legs extended or slightly bent. '
          'Lengthen through the spine and relax the shoulders.',
      goal: 'A tall, grounded seat that prepares for seated work.',
      entrySteps: [
        'Sit on a folded blanket.',
        'Extend the legs or keep the knees slightly bent.',
      ],
      exitSteps: ['Bend the knees and relax.'],
      breathCues: ['Let the breath lengthen the spine on each inhale.'],
      alignmentCues: ['Lengthen through the spine.', 'Relax the shoulders.'],
      avoid: ['Rounding the lower back', 'Locking the knees'],
      modifications: [
        YogaModification('Bend the knees and sit higher on the blanket.'),
        YogaModification(
          'Bend the knees and sit on a higher blanket.',
          caution: YogaCaution.back,
        ),
      ],
      holdSeconds: 30,
      holdGuidance: 'Sit for 4–6 breaths.',
      imageUrl: AppImages.yogaDandasana,
      props: [YogaProp.blanket],
      met: 1.8,
      muscleShares: {'Core': 0.3, 'Hamstrings': 0.3},
    ),
    YogaPosture(
      id: 'sukhasana',
      name: 'Easy Pose',
      sanskritName: 'Sukhasana',
      family: YogaFamily.seated,
      summary:
          'Cross legs comfortably on a cushion. If hips or knees are '
          'uncomfortable, sit on a chair with feet grounded.',
      goal: 'A comfortable seat for breathing and seated mobility.',
      entrySteps: [
        'Sit on a cushion and cross the legs comfortably.',
        'Rest the hands on the knees.',
      ],
      exitSteps: ['Uncross the legs and stretch them out.'],
      breathCues: ['Observe the natural breath.'],
      alignmentCues: ['Hips slightly higher than knees.', 'Spine tall.'],
      avoid: ['Slumping', 'Forcing the knees down'],
      modifications: [
        YogaModification('Sit on a chair with feet grounded.'),
        YogaModification(
          'Sit on a chair with feet grounded.',
          caution: YogaCaution.knee,
        ),
      ],
      holdSeconds: 45,
      holdGuidance: 'Sit for 5–8 breaths, switching the cross halfway.',
      imageUrl: AppImages.yogaSukhasana,
      props: [YogaProp.cushion, YogaProp.chair],
      met: 1.5,
      muscleShares: {'Core': 0.2, 'Glutes': 0.2},
    ),
    YogaPosture(
      id: 'baddha-konasana',
      name: 'Bound Angle Pose',
      sanskritName: 'Baddha Konasana',
      family: YogaFamily.seated,
      summary:
          'Bring soles of feet together and let knees open naturally. '
          'Support thighs with cushions; do not press knees down.',
      goal: 'A gentle opening for the hips and inner thighs.',
      entrySteps: [
        'Sit on a blanket and bring the soles of the feet together.',
        'Let the knees open naturally onto cushions.',
      ],
      exitSteps: ['Use the hands to bring the knees together.'],
      breathCues: ['Breathe softly; let the hips release on each exhale.'],
      alignmentCues: [
        'Support the thighs with cushions.',
        'Do not press the knees down.',
      ],
      avoid: ['Pushing the knees toward the floor'],
      modifications: [
        YogaModification('Move the feet further from the body.'),
        YogaModification(
          'Place cushions under both thighs and move the feet further away.',
          caution: YogaCaution.knee,
        ),
      ],
      holdSeconds: 45,
      holdGuidance: 'Hold for 5–8 breaths.',
      imageUrl: AppImages.yogaBaddhaKonasana,
      props: [YogaProp.blanket, YogaProp.cushion, YogaProp.blocks],
      met: 1.8,
      muscleShares: {'Glutes': 0.3},
    ),
    YogaPosture(
      id: 'paschimottanasana',
      name: 'Seated Forward Fold',
      sanskritName: 'Paschimottanasana',
      family: YogaFamily.seated,
      summary:
          'Sit on a blanket, bend knees as needed and hinge forward from the '
          'hips. Use a strap around the feet without pulling.',
      goal: 'A gentle stretch for the back of the legs.',
      entrySteps: [
        'Sit on a blanket with legs forward and knees bent as needed.',
        'Loop a strap around the feet and hinge forward from the hips.',
      ],
      exitSteps: ['Release the strap and roll up slowly.'],
      breathCues: ['Inhale to lengthen, exhale to hinge a little.'],
      alignmentCues: [
        'Hinge from the hips, not the waist.',
        'Bend the knees as needed.',
      ],
      avoid: ['Pulling on the strap', 'Rounding hard to reach the toes'],
      modifications: [
        YogaModification('Keep the knees well bent.'),
        YogaModification(
          'Keep the knees well bent and the fold small.',
          caution: YogaCaution.back,
        ),
      ],
      holdSeconds: 40,
      holdGuidance: 'Hold for 5–6 breaths.',
      imageUrl: AppImages.yogaPaschimottanasana,
      props: [YogaProp.blanket, YogaProp.strap],
      met: 1.8,
      muscleShares: {'Hamstrings': 0.6, 'Back': 0.2},
    ),
    YogaPosture(
      id: 'janu-sirsasana',
      name: 'Head-to-Knee Pose',
      sanskritName: 'Janu Sirsasana',
      family: YogaFamily.seated,
      summary:
          'Bend one knee with the foot supported and fold only slightly over '
          'the straight leg. Keep both hips comfortable.',
      goal: 'A one-sided stretch for the back of the leg.',
      entrySteps: [
        'Sit on a blanket, extend one leg and bend the other.',
        'Fold only slightly over the straight leg.',
      ],
      exitSteps: ['Roll up slowly and switch legs.'],
      breathCues: ['Exhale to soften into the fold.'],
      alignmentCues: [
        'Support the bent knee if it lifts.',
        'Fold only slightly.',
      ],
      avoid: ['Pulling the torso down'],
      modifications: [
        YogaModification('Bend the extended knee.'),
        YogaModification(
          'Place a cushion under the bent knee.',
          caution: YogaCaution.knee,
        ),
      ],
      holdSeconds: 30,
      holdGuidance: 'Hold for 4–5 breaths on each side.',
      imageUrl: AppImages.yogaJanuSirsasana,
      props: [YogaProp.blanket, YogaProp.cushion, YogaProp.strap],
      isPerSide: true,
      met: 1.8,
      muscleShares: {'Hamstrings': 0.5, 'Back': 0.2},
    ),
    YogaPosture(
      id: 'bharadvajasana',
      name: 'Seated Twist',
      sanskritName: 'Bharadvajasana',
      family: YogaFamily.seated,
      summary:
          'Sit tall and rotate the torso slightly without pulling on the knee '
          'or forcing the neck. Keep the twist easy.',
      goal: 'A gentle rotation for the spine.',
      entrySteps: [
        'Sit tall on a cushion or chair.',
        'Rotate the torso slightly, one hand on the opposite knee.',
      ],
      exitSteps: ['Return to centre on an inhale and switch sides.'],
      breathCues: ['Inhale to grow tall, exhale to turn a little.'],
      alignmentCues: ['Sit tall before you turn.', 'Keep the twist easy.'],
      avoid: ['Pulling on the knee', 'Forcing the neck'],
      modifications: [
        YogaModification('Practise seated on a chair.'),
        YogaModification(
          'Keep the head facing forward and turn only the chest.',
          caution: YogaCaution.neck,
        ),
        YogaModification(
          'Make the twist very small.',
          caution: YogaCaution.back,
        ),
      ],
      holdSeconds: 25,
      holdGuidance: 'Hold for 3–5 breaths on each side.',
      imageUrl: AppImages.yogaBharadvajasana,
      props: [YogaProp.cushion, YogaProp.chair],
      isPerSide: true,
      met: 1.8,
      muscleShares: {'Core': 0.4, 'Back': 0.3},
    ),
    YogaPosture(
      id: 'seated-side-bend',
      name: 'Seated Side Bend',
      sanskritName: 'Parsvottanasana (seated)',
      family: YogaFamily.seated,
      summary:
          'Keep one or both hands grounded and lean sideways gently. Avoid '
          'collapsing into the shoulder.',
      goal: 'Open the side body from a supported seat.',
      entrySteps: [
        'Sit tall on a cushion or chair.',
        'Ground one hand and lean gently to that side.',
      ],
      exitSteps: ['Return upright on an inhale and switch sides.'],
      breathCues: ['Breathe into the lengthening side.'],
      alignmentCues: [
        'Keep one or both hands grounded.',
        'Lean sideways, not forward.',
      ],
      avoid: ['Collapsing into the shoulder'],
      modifications: [
        YogaModification(
          'Keep both hands down and make the lean small.',
          caution: YogaCaution.shoulder,
        ),
      ],
      holdSeconds: 20,
      holdGuidance: 'Hold for 3–4 breaths on each side.',
      imageUrl: AppImages.yogaSeatedSideBend,
      props: [YogaProp.cushion, YogaProp.chair],
      isPerSide: true,
      met: 1.8,
      muscleShares: {'Core': 0.4, 'Shoulders': 0.2},
    ),
    YogaPosture(
      id: 'apanasana',
      name: 'Knees-to-Chest',
      sanskritName: 'Apanasana',
      family: YogaFamily.supine,
      summary:
          'Draw one knee at a time toward the torso, holding behind the '
          'thigh. Keep the other leg relaxed and stop if the back or hip '
          'feels pinched.',
      goal: 'A gentle release for the lower back and hips.',
      entrySteps: [
        'Lie on the back with knees bent.',
        'Draw one knee toward the torso, holding behind the thigh.',
      ],
      exitSteps: ['Lower the foot to the floor and switch legs.'],
      breathCues: ['Exhale as the knee draws in, inhale as it eases away.'],
      alignmentCues: [
        'Hold behind the thigh, not the knee.',
        'Keep the other leg relaxed.',
      ],
      avoid: ['Pulling hard', 'Continuing if the hip feels pinched'],
      modifications: [
        YogaModification('Keep the other foot on the floor with knee bent.'),
        YogaModification(
          'Hold behind the thigh and keep the knee bend comfortable.',
          caution: YogaCaution.knee,
        ),
      ],
      holdSeconds: 25,
      holdGuidance: 'Hold for 3–5 breaths on each side.',
      imageUrl: AppImages.yogaApanasana,
      props: [YogaProp.mat, YogaProp.blanket],
      isPerSide: true,
      met: 1.5,
      muscleShares: {'Glutes': 0.3, 'Back': 0.2},
    ),
    YogaPosture(
      id: 'supta-matsyendrasana',
      name: 'Supine Twist',
      sanskritName: 'Supta Matsyendrasana',
      family: YogaFamily.supine,
      summary:
          'With knees bent, let both knees move a small distance to one side. '
          'Keep shoulders comfortable and use a cushion under knees.',
      goal: 'A restful twist for the spine.',
      entrySteps: [
        'Lie on the back with knees bent and feet on the floor.',
        'Let both knees move a small distance to one side.',
      ],
      exitSteps: ['Bring the knees back to centre on an inhale.'],
      breathCues: ['Let each exhale soften the twist.'],
      alignmentCues: [
        'Keep the shoulders comfortable.',
        'Support the knees with a cushion.',
      ],
      avoid: ['Dropping the knees all the way down'],
      modifications: [
        YogaModification('Rest the knees on a cushion.'),
        YogaModification(
          'Keep the twist very small with a cushion under the knees.',
          caution: YogaCaution.back,
        ),
        YogaModification(
          'Keep the head facing the ceiling.',
          caution: YogaCaution.neck,
        ),
      ],
      holdSeconds: 30,
      holdGuidance: 'Hold for 4–6 breaths on each side.',
      imageUrl: AppImages.yogaSuptaMatsyendrasana,
      props: [YogaProp.mat, YogaProp.cushion],
      isPerSide: true,
      met: 1.5,
      muscleShares: {'Back': 0.3, 'Core': 0.2},
    ),
    YogaPosture(
      id: 'setu-bandha',
      name: 'Bridge Pose',
      sanskritName: 'Setu Bandha Sarvangasana',
      family: YogaFamily.supine,
      summary:
          'Press through the feet and lift the pelvis a small amount. Keep '
          'the neck still; use pelvic tilts instead if lifting is '
          'uncomfortable.',
      goal: 'Gentle strength for the hips and back of the legs.',
      entrySteps: [
        'Lie on the back with knees bent, feet hip-width apart.',
        'Press through the feet and lift the pelvis a small amount.',
      ],
      exitSteps: ['Lower the spine slowly to the mat.'],
      breathCues: ['Inhale to lift, exhale to lower.'],
      alignmentCues: ['Keep the neck still.', 'Lift only a small amount.'],
      avoid: ['Turning the head while lifted', 'Lifting high'],
      modifications: [YogaModification('Use pelvic tilts instead.')],
      holdSeconds: 20,
      holdGuidance: 'Three to five slow lifts.',
      imageUrl: AppImages.yogaSetuBandha,
      props: [YogaProp.mat, YogaProp.blanket],
      cautions: {YogaCaution.neck, YogaCaution.back},
      alternativeId: 'pelvic-tilts',
      met: 2.5,
      muscleShares: {'Glutes': 0.6, 'Hamstrings': 0.4, 'Core': 0.2},
    ),
    YogaPosture(
      id: 'pelvic-tilts',
      name: 'Pelvic Tilts',
      family: YogaFamily.supine,
      summary:
          'Lying with knees bent, gently tilt the pelvis to flatten and then '
          'release the lower back. A low-load alternative to Bridge.',
      goal: 'Gentle core and lower-back movement without lifting.',
      entrySteps: [
        'Lie on the back with knees bent and feet flat.',
        'Gently press the lower back toward the floor, then release.',
      ],
      exitSteps: ['Rest with the spine neutral.'],
      breathCues: ['Exhale to tilt, inhale to release.'],
      alignmentCues: ['Keep the movement small.', 'Neck stays still.'],
      avoid: ['Lifting the hips', 'Holding the breath'],
      modifications: [
        YogaModification('Place a folded blanket under the head.'),
      ],
      holdSeconds: 30,
      holdGuidance: 'Eight to ten slow tilts.',
      imageUrl: AppImages.yogaPelvicTilts,
      props: [YogaProp.mat, YogaProp.blanket],
      met: 1.8,
      muscleShares: {'Core': 0.4, 'Glutes': 0.2},
    ),
    YogaPosture(
      id: 'supta-baddha-konasana',
      name: 'Reclined Bound Angle',
      sanskritName: 'Supta Baddha Konasana',
      family: YogaFamily.supine,
      summary:
          'Lie on the back with soles of feet together and knees supported '
          'by cushions. Do not let the knees hang unsupported.',
      goal: 'A restful hip opening.',
      entrySteps: [
        'Lie on the back and bring the soles of the feet together.',
        'Support both knees with cushions.',
      ],
      exitSteps: ['Use the hands to bring the knees together.'],
      breathCues: ['Rest with a natural, easy breath.'],
      alignmentCues: ['Knees always supported.'],
      avoid: ['Letting the knees hang unsupported'],
      modifications: [
        YogaModification('Keep the feet hip-width apart with knees bent.'),
      ],
      holdSeconds: 60,
      holdGuidance: 'Rest for 1–2 minutes.',
      imageUrl: AppImages.yogaSuptaBaddhaKonasana,
      props: [YogaProp.cushion, YogaProp.bolster, YogaProp.blanket],
      met: 1.3,
      muscleShares: {'Glutes': 0.2},
    ),
    YogaPosture(
      id: 'pavanamuktasana',
      name: 'Wind-Relieving Pose',
      sanskritName: 'Pavanamuktasana',
      family: YogaFamily.supine,
      summary:
          'Bring one knee toward the torso, then switch sides. Avoid '
          'compressing the abdomen or forcing the knee.',
      goal: 'A gentle release for the hips and lower back.',
      entrySteps: [
        'Lie on the back with knees bent.',
        'Bring one knee toward the torso.',
      ],
      exitSteps: ['Lower the foot and switch sides.'],
      breathCues: ['Breathe easily without compressing the belly.'],
      alignmentCues: ['Move one knee at a time.'],
      avoid: ['Compressing the abdomen', 'Forcing the knee'],
      modifications: [YogaModification('Hold behind the thigh.')],
      holdSeconds: 25,
      holdGuidance: 'Hold for 3–5 breaths on each side.',
      imageUrl: AppImages.yogaPavanamuktasana,
      props: [YogaProp.mat],
      isPerSide: true,
      met: 1.5,
      muscleShares: {'Glutes': 0.3},
    ),
    YogaPosture(
      id: 'makarasana',
      name: 'Crocodile Rest',
      sanskritName: 'Makarasana',
      family: YogaFamily.supine,
      summary:
          'Lie on the belly with forehead on stacked hands, or choose '
          'side-lying rest if prone position is uncomfortable.',
      goal: 'A restful shape that lets the breath move into the back.',
      entrySteps: [
        'Lie on the belly.',
        'Stack the hands and rest the forehead on them.',
      ],
      exitSteps: ['Roll to one side and press up slowly.'],
      breathCues: ['Feel the belly press gently into the floor as you inhale.'],
      alignmentCues: ['Keep the neck neutral.'],
      avoid: ['Turning the head sharply'],
      modifications: [
        YogaModification('Rest on the side with a cushion between the knees.'),
        YogaModification(
          'Choose side-lying rest instead of lying on the belly.',
          caution: YogaCaution.back,
        ),
      ],
      holdSeconds: 45,
      holdGuidance: 'Rest for 5–8 breaths.',
      imageUrl: AppImages.yogaMakarasana,
      props: [YogaProp.mat, YogaProp.cushion],
      met: 1.3,
      muscleShares: {'Back': 0.1},
    ),
    YogaPosture(
      id: 'cobra-pose',
      name: 'Low Cobra',
      sanskritName: 'Bhujangasana',
      family: YogaFamily.supine,
      summary:
          'Lie on the belly, hands near ribs and elbows bent. Lift the chest '
          'slightly without pushing hard through the hands. Skip with '
          'shoulder or back pain.',
      goal: 'A small, gentle backbend.',
      entrySteps: [
        'Lie on the belly with hands near the ribs and elbows bent.',
        'Lift the chest slightly.',
      ],
      exitSteps: ['Lower the chest slowly and rest the forehead down.'],
      breathCues: ['Inhale to lift a little, exhale to lower.'],
      alignmentCues: [
        'Elbows stay bent.',
        'Do not push hard through the hands.',
      ],
      avoid: ['Straightening the arms', 'Lifting high'],
      modifications: [YogaModification('Rest in Crocodile pose instead.')],
      holdSeconds: 15,
      holdGuidance: 'Two to three small lifts.',
      imageUrl: AppImages.cobraPose,
      props: [YogaProp.mat],
      cautions: {YogaCaution.shoulder, YogaCaution.back, YogaCaution.wrist},
      alternativeId: 'makarasana',
      isOptional: true,
      met: 2,
      muscleShares: {'Back': 0.5, 'Core': 0.2},
    ),
    YogaPosture(
      id: savasanaId,
      name: 'Final Relaxation',
      sanskritName: 'Savasana',
      family: YogaFamily.supine,
      summary:
          'Lie comfortably with support under knees or head, or rest on the '
          'side or in a chair. Let breathing remain natural.',
      goal: 'Rest completely and let the practice settle.',
      entrySteps: [
        'Lie on the back with a cushion under the knees and head.',
        'Let the arms rest away from the body, palms up.',
      ],
      exitSteps: [
        'Deepen the breath gently and move the fingers and toes.',
        'Roll to one side and return gradually to sitting.',
      ],
      breathCues: ['Let breathing remain natural.'],
      alignmentCues: ['Support under knees or head.'],
      avoid: ['Getting up quickly'],
      modifications: [
        YogaModification('Rest on the side or in a chair.'),
        YogaModification(
          'Place a cushion under the knees.',
          caution: YogaCaution.back,
        ),
      ],
      holdSeconds: 180,
      holdGuidance: 'Rest for 3–5 minutes.',
      imageUrl: AppImages.yogaSavasana,
      props: [YogaProp.mat, YogaProp.cushion, YogaProp.blanket],
      met: 1.2,
      muscleShares: {'Core': 0.1},
    ),
  ];
}
