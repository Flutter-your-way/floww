import 'package:flutter/material.dart';

import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';

extension PremiumFeatureToneColor on PremiumFeatureTone {
  Color resolve(BuildContext context) => switch (this) {
    PremiumFeatureTone.primary => context.colors.primary,
    PremiumFeatureTone.success => context.colors.success,
    PremiumFeatureTone.violet => context.colors.accentViolet,
  };
}
