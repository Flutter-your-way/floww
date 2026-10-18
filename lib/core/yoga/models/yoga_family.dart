enum YogaFamily {
  warmUp('Warm-up & breath', 'Gentle mobility and breath awareness to arrive.'),
  standing(
    'Standing postures',
    'Teach the foundation first: stable feet, relaxed shoulders, comfortable '
        'knees and a steady breath. Use a wall or chair for balance.',
  ),
  kneeling(
    'Kneeling and tabletop',
    'Kneeling is optional. Add a folded blanket beneath the knees and come '
        'out of the pose if pressure or pain develops. Do not force deep knee '
        'flexion.',
  ),
  seated(
    'Seated postures',
    'Sit on a folded blanket or cushion so the spine can lengthen without '
        'strain.',
  ),
  supine(
    'Supine and prone postures',
    'Move slowly when lying down and getting up. Use a folded blanket or '
        'cushion for comfort, and keep the neck neutral.',
  );

  const YogaFamily(this.title, this.intro);

  final String title;
  final String intro;
}
