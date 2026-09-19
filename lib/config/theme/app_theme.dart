import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/theme/app_mode_intensity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_typography.dart';
import 'app_theme_tokens.dart';

class AppTheme {
  AppTheme._();

  static AppColorTokens colorsOf(AppThemeMode mode) => switch (mode) {
    AppThemeMode.flow => AppColorTokens.flow,
    AppThemeMode.steady => AppColorTokens.steady,
    AppThemeMode.restore => AppColorTokens.restore,
  };

  static AppGradientTokens gradientsOf(AppThemeMode mode) => switch (mode) {
    AppThemeMode.flow => AppGradientTokens.flow,
    AppThemeMode.steady => AppGradientTokens.steady,
    AppThemeMode.restore => AppGradientTokens.restore,
  };

  static ThemeData buildTheme(AppThemeMode mode) {
    final colorTokens = colorsOf(mode);
    final gradientTokens = gradientsOf(mode);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'HankenGrotesk',
      scaffoldBackgroundColor: colorTokens.backgroundPrimary,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme.dark(
        primary: colorTokens.primary,
        onPrimary: colorTokens.backgroundPrimary,
        secondary: colorTokens.primaryDeep,
        onSecondary: colorTokens.backgroundPrimary,
        surface: colorTokens.backgroundSurface,
        onSurface: colorTokens.textPrimary,
        error: colorTokens.destructive,
        onError: colorTokens.textPrimary,
        outline: colorTokens.borderMedium,
        outlineVariant: colorTokens.borderSubtle,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: colorTokens.textPrimary,
        titleTextStyle: AppTypography.heading4.copyWith(
          color: colorTokens.textPrimary,
        ),
      ),
      textTheme:
          TextTheme(
            displayLarge: AppTypography.heading1,
            displayMedium: AppTypography.heading2Bold,
            displaySmall: AppTypography.heading3Bold,
            headlineSmall: AppTypography.heading3Medium,
            titleLarge: AppTypography.heading4,
            titleMedium: AppTypography.bodyLargeMedium,
            titleSmall: AppTypography.bodyLargeMedium,
            bodyLarge: AppTypography.bodyLargeMedium,
            bodyMedium: AppTypography.bodyMediumRegular,
            bodySmall: AppTypography.bodySmallMedium,
            labelLarge: AppTypography.bodyMediumBold,
            labelMedium: AppTypography.bodySmallSemiBold,
            labelSmall: AppTypography.bodyXSmallMedium,
          ).apply(
            displayColor: colorTokens.textPrimary,
            bodyColor: colorTokens.textPrimary,
          ),
      extensions: [colorTokens, gradientTokens, AppModeIntensity.of(mode)],
    );
  }
}
