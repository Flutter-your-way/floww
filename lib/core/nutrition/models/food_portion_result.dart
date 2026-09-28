import 'package:floww/core/nutrition/models/food_catalog.dart';

class FoodPortionResult {
  const FoodPortionResult.save(CatalogFood this.portion);

  const FoodPortionResult.remove() : portion = null;

  final CatalogFood? portion;

  bool get isRemoval => portion == null;
}
