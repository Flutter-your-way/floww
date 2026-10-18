enum YogaCaution {
  knee('Knee'),
  shoulder('Shoulder'),
  wrist('Wrist'),
  back('Back'),
  neck('Neck');

  const YogaCaution(this.label);

  final String label;

  static Set<YogaCaution> fromLabels(Iterable<String> labels) {
    final normalized = {for (final label in labels) label.trim().toLowerCase()};
    return {
      for (final caution in values)
        if (normalized.contains(caution.label.toLowerCase())) caution,
    };
  }
}
