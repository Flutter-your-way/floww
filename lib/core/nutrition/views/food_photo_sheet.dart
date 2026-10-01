import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/sheets/app_info_sheet.dart';
import 'package:floww/config/widgets/sheets/app_option_sheet.dart';
import 'package:floww/core/nutrition/providers/food_photo_provider.dart';
import 'package:floww/core/nutrition/services/food_image_service.dart';

class FoodPhotoSheet {
  FoodPhotoSheet._();

  static Future<void> show(BuildContext context, String name) async {
    HapticManager.light();
    final provider = context.read<FoodPhotoProvider>();
    final action = await AppOptionSheet.show(
      context,
      title: name,
      icon: Icons.photo_outlined,
      options: provider.optionsFor(name),
    );
    if (action == null) return;

    try {
      await provider.apply(name, action);
    } on FoodImageException catch (e) {
      if (!context.mounted) return;
      AppInfoSheet.show(
        context,
        title: 'Photo not updated',
        message: e.message,
      );
    }
  }
}
