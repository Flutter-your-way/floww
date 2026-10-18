enum YogaProp {
  mat('Mat', 'A non-slip mat', 'Yoga Mat', 'A rug or any non-slip surface'),
  blocks('Blocks', 'Yoga blocks', 'Blocks', 'A stack of thick books'),
  strap('Strap', 'A yoga strap', 'Strap', 'A belt, scarf or towel'),
  bolster('Bolster', 'A bolster', 'Bolster', 'Firm pillows or a rolled blanket'),
  blanket('Blanket', 'A folded blanket', null, 'A folded towel'),
  cushion('Cushion', 'A cushion', null, 'A folded blanket or pillow'),
  chair('Chair', 'A sturdy chair', null, 'A kitchen counter or table edge'),
  wall('Wall', 'A clear wall', null, 'A sturdy door frame');

  const YogaProp(this.label, this.text, this.onboardingLabel, this.substitute);

  final String label;
  final String text;
  final String? onboardingLabel;
  final String substitute;

  bool isOwnedIn(Set<String> ownedLabels) {
    final onboarding = onboardingLabel;
    return onboarding == null || ownedLabels.contains(onboarding);
  }
}
