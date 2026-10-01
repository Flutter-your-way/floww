import 'package:floww/config/constants/app_images.dart';
import 'package:floww/core/nutrition/models/food_image_key.dart';

class FoodPhotoCatalog {
  FoodPhotoCatalog._();

  static const Map<String, String> _byName = {
    'Chicken Breast': AppImages.foodChickenBreast,
    'Brown Rice': AppImages.foodBrownRice,
    'Whole Eggs': AppImages.foodWholeEggs,
    'Greek Yogurt': AppImages.foodGreekYogurt,
    'Oats': AppImages.foodOats,
    'Salmon': AppImages.foodSalmon,
    'Banana': AppImages.foodBanana,
    'Apple': AppImages.foodApple,
    'Avocado': AppImages.foodAvocado,
    'Almonds': AppImages.foodAlmonds,
    'Whole Wheat Bread': AppImages.foodWholeWheatBread,
    'Milk (2%)': AppImages.foodMilk2,
    'Broccoli': AppImages.foodBroccoli,
    'Sweet Potato': AppImages.foodSweetPotato,
    'Quinoa': AppImages.foodQuinoa,
    'Firm Tofu': AppImages.foodFirmTofu,
    'Lentils': AppImages.foodLentils,
    'Paneer': AppImages.foodPaneer,
    'White Rice': AppImages.foodWhiteRice,
    'Chapati': AppImages.foodChapati,
    'Peanut Butter': AppImages.foodPeanutButter,
    'Orange Juice': AppImages.foodOrangeJuice,
    'Whey Protein Shake': AppImages.foodWheyProteinShake,
    'Mixed Greens': AppImages.foodMixedGreens,
    'Olive Oil': AppImages.foodOliveOil,
    'Cottage Cheese': AppImages.foodCottageCheese,
    'Pasta': AppImages.foodPasta,
    'Beef Steak': AppImages.foodBeefSteak,
    'Canned Tuna': AppImages.foodCannedTuna,
    'Dark Chocolate': AppImages.foodDarkChocolate,
  };

  static final Map<String, String> _byKey = {
    for (final entry in _byName.entries)
      FoodImageKey.of(entry.key): entry.value,
  };

  static String? of(String key) => _byKey[key];
}
