enum WavePremiumFeature {
  memory('Long-term memory'),
  proactiveCoaching('Proactive coaching'),
  planEdits('Plan edits from chat'),
  weeklyReviews('Weekly reviews');

  const WavePremiumFeature(this.label);

  final String label;

  static List<WavePremiumFeature> listOf(Object? value) => value is List
      ? [for (final item in value) ?WavePremiumFeature.values.asNameMap()[item]]
      : const [];
}
