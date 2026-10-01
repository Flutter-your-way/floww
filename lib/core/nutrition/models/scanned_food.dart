import 'dart:typed_data';

import 'package:floww/core/nutrition/models/food_model.dart';

class ScannedFood {
  const ScannedFood({required this.food, required this.photo});

  final FoodModel food;
  final Uint8List photo;
}
