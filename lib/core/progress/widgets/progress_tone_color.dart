import 'package:flutter/material.dart';

import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';

extension ProgressToneColor on ProgressTone {
  Color resolve(BuildContext context) => switch (this) {
    ProgressTone.primary => context.colors.primaryAlt,
    ProgressTone.accent => context.colors.accentOrange,
    ProgressTone.neutral => context.colors.fatAccent,
  };

  Color resolveValue(BuildContext context) => switch (this) {
    ProgressTone.primary => context.colors.primaryAlt,
    ProgressTone.accent => context.colors.accentOrange,
    ProgressTone.neutral => context.colors.textQuiet,
  };
}
