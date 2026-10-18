enum CalGear {
  pullUpBar('Pull-up Bar'),
  rings('Rings'),
  bands('Bands'),
  parallettes('Parallettes'),
  dipBars('Dip Bars');

  const CalGear(this.label);

  final String label;

  static Set<CalGear> fromLabels(Iterable<String> labels) {
    final owned = {for (final label in labels) label.trim().toLowerCase()};
    return {
      for (final gear in values)
        if (owned.contains(gear.label.toLowerCase())) gear,
    };
  }
}
