class FoodImageKey {
  FoodImageKey._();

  static final RegExp _separators = RegExp(r'[^a-z0-9]+');
  static final RegExp _edges = RegExp(r'^-+|-+$');

  static String of(String name) => name
      .trim()
      .toLowerCase()
      .replaceAll(_separators, '-')
      .replaceAll(_edges, '');
}
