import 'package:floww/config/constants/app_sizes.dart';
import 'package:flutter/material.dart';

extension FlowwThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get scheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  AppColorTokens get colors => theme.extension<AppColorTokens>()!;

  AppGradientTokens get gradients => theme.extension<AppGradientTokens>()!;

  AppLayoutSizes get sizes => const AppLayoutSizes();
}

class _AppPalette {
  const _AppPalette._();

  static const backgroundPrimary = Color(0xFF0A0A0A);
  static const backgroundSecondary = Color(0xFF181818);
  static const backgroundSurface = Color(0xFF1F1F1F);
  static const backgroundElevated = Color(0xFF2D2D2D);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x80FFFFFF);
  static const textTertiary = Color(0x33FFFFFF);
  static const textFaint = Color(0x59FFFFFF);
  static const textMuted = Color(0xFF999999);
  static const textQuiet = Color(0xFF919191);
  static const textDim = Color(0xFF767676);
  static const textSubtle = Color(0x99FFFFFF);
  static const surfaceTranslucent = Color(0x331D1E1D);

  static const borderSubtle = Color(0x1AFFFFFF);
  static const borderMedium = Color(0x33FFFFFF);

  static const destructive = Color(0xFFDC2626);
  static const destructiveBorder = Color(0xFFEF4444);
  static const destructiveOutline = Color(0x66EF4444);
  static const destructiveTint = Color(0x1FDC2626);
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFACC15);
  static const brandLight = Color(0xFFFFFFFF);
  static const onBrandLight = Color(0xFF0A0A0A);

  static const scrim = Color(0x990A0A0A);
  static const proteinAccent = Color(0xFFC3FF3D);
  static const carbsAccent = Color(0xFFF97316);
  static const fatAccent = Color(0xFF28D5E6);
  static const fiberAccent = Color(0xFF4ADE80);
  static const accentOrangeMuted = Color(0x80F97316);
  static const accentOrangeDeep = Color(0xFFEA580C);
  static const accentOrangeLight = Color(0xFFFB923C);
  static const amberBorder = Color(0x3DF59E0B);
  static const amberSurface = Color(0x10F59E0B);
  static const accentViolet = Color(0xFF8B5CF6);
}

class _MacroGradients {
  const _MacroGradients._();

  static const _trackEnd = Color(0xFF0F0E0B);

  static const protein = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFEC4899), _trackEnd],
    stops: [0.0, 0.3371, 0.6742],
  );

  static const carbs = LinearGradient(
    colors: [Color(0xFF2E90FA), Color(0xFF0EA5E9), _trackEnd],
    stops: [0.0, 0.2735, 0.547],
  );

  static const fats = LinearGradient(
    colors: [Color(0xFFEF6820), Color(0xFFFAC515), _trackEnd],
    stops: [0.0, 0.3746, 0.7491],
  );
}

class _OverlayGradients {
  const _OverlayGradients._();

  static const cameraScrim = LinearGradient(
    colors: [Color(0x800A0A0A), _AppPalette.backgroundPrimary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const cardSheen = RadialGradient(
    colors: [Color(0xFF1D1D1D), Color(0x001D1D1D)],
    center: Alignment.topRight,
    radius: 1.6,
  );

  static const actionScrim = LinearGradient(
    colors: [
      Color(0x000A0A0A),
      Color(0xCC0A0A0A),
      _AppPalette.backgroundPrimary,
    ],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.primary,
    required this.primaryDeep,
    required this.primaryAlt,
    required this.tint,
    required this.tintStrong,
    required this.borderGlow,
    required this.borderAccent,
    required this.bgTinted,
    required this.bgWarm,
    required this.accentOrange,
    required this.surfaceBright,
    required this.onSurfaceBright,
    this.backgroundPrimary = _AppPalette.backgroundPrimary,
    this.backgroundSecondary = _AppPalette.backgroundSecondary,
    this.backgroundSurface = _AppPalette.backgroundSurface,
    this.backgroundElevated = _AppPalette.backgroundElevated,
    this.textPrimary = _AppPalette.textPrimary,
    this.textSecondary = _AppPalette.textSecondary,
    this.textTertiary = _AppPalette.textTertiary,
    this.textFaint = _AppPalette.textFaint,
    this.textMuted = _AppPalette.textMuted,
    this.textQuiet = _AppPalette.textQuiet,
    this.textDim = _AppPalette.textDim,
    this.textSubtle = _AppPalette.textSubtle,
    this.surfaceTranslucent = _AppPalette.surfaceTranslucent,
    this.borderSubtle = _AppPalette.borderSubtle,
    this.borderMedium = _AppPalette.borderMedium,
    this.destructive = _AppPalette.destructive,
    this.destructiveBorder = _AppPalette.destructiveBorder,
    this.destructiveOutline = _AppPalette.destructiveOutline,
    this.destructiveTint = _AppPalette.destructiveTint,
    this.success = _AppPalette.success,
    this.warning = _AppPalette.warning,
    this.brandLight = _AppPalette.brandLight,
    this.onBrandLight = _AppPalette.onBrandLight,
    this.glassSurface = _AppPalette.textSecondary,
    this.scrim = _AppPalette.scrim,
    this.proteinAccent = _AppPalette.proteinAccent,
    this.carbsAccent = _AppPalette.carbsAccent,
    this.fatAccent = _AppPalette.fatAccent,
    this.fiberAccent = _AppPalette.fiberAccent,
    this.accentOrangeMuted = _AppPalette.accentOrangeMuted,
    this.accentOrangeDeep = _AppPalette.accentOrangeDeep,
    this.accentOrangeLight = _AppPalette.accentOrangeLight,
    this.amberBorder = _AppPalette.amberBorder,
    this.amberSurface = _AppPalette.amberSurface,
    this.accentViolet = _AppPalette.accentViolet,
  });

  final Color primary;
  final Color primaryDeep;
  final Color primaryAlt;
  final Color tint;
  final Color tintStrong;
  final Color borderGlow;
  final Color borderAccent;
  final Color bgTinted;
  final Color bgWarm;
  final Color accentOrange;
  final Color surfaceBright;
  final Color onSurfaceBright;

  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color backgroundSurface;
  final Color backgroundElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textFaint;
  final Color textMuted;
  final Color textQuiet;
  final Color textDim;
  final Color textSubtle;
  final Color surfaceTranslucent;
  final Color borderSubtle;
  final Color borderMedium;
  final Color destructive;
  final Color destructiveBorder;
  final Color destructiveOutline;
  final Color destructiveTint;
  final Color success;
  final Color warning;
  final Color brandLight;
  final Color onBrandLight;
  final Color glassSurface;
  final Color scrim;
  final Color proteinAccent;
  final Color carbsAccent;
  final Color fatAccent;
  final Color fiberAccent;
  final Color accentOrangeMuted;
  final Color accentOrangeDeep;
  final Color accentOrangeLight;
  final Color amberBorder;
  final Color amberSurface;
  final Color accentViolet;

  static const flow = AppColorTokens(
    primary: Color(0xFFC3FF3D),
    primaryDeep: Color(0xFF84CC16),
    primaryAlt: Color(0xFFBAFF1F),
    tint: Color(0x14C3FF3D),
    tintStrong: Color(0x14C3FF3D),
    borderGlow: Color(0x3DC3FF3D),
    borderAccent: Color(0x80C3FF3D),
    bgTinted: Color(0xFF1F2218),
    bgWarm: Color(0xFF23221A),
    accentOrange: Color(0xFFF97316),
    surfaceBright: Color(0xFFE0EBE2),
    onSurfaceBright: Color(0xFF659100),
  );

  static const steady = AppColorTokens(
    primary: Color(0xFFF97316),
    primaryDeep: Color(0xFFD55900),
    primaryAlt: Color(0xFFF59E0B),
    tint: Color(0x14F97316),
    tintStrong: Color(0x14F97316),
    borderGlow: Color(0x3DF59E0B),
    borderAccent: Color(0x80F97316),
    bgTinted: Color(0xFF221C18),
    bgWarm: Color(0xFF23221A),
    accentOrange: Color(0xFFF97316),
    surfaceBright: Color(0xFFEBE4E0),
    onSurfaceBright: Color(0xFF8C3F00),
  );

  static const restore = AppColorTokens(
    primary: Color(0xFF28D5E6),
    primaryDeep: Color(0xFF00C4D5),
    primaryAlt: Color(0xFF22CDE6),
    tint: Color(0x1422CDE6),
    tintStrong: Color(0x1728D5E6),
    borderGlow: Color(0x3D22CDE6),
    borderAccent: Color(0x8028D5E6),
    bgTinted: Color(0xFF182122),
    bgWarm: Color(0xFF182122),
    accentOrange: Color(0xFFF97316),
    surfaceBright: Color(0xFFE0EAEB),
    onSurfaceBright: Color(0xFF00697A),
  );

  @override
  AppColorTokens copyWith({
    Color? primary,
    Color? primaryDeep,
    Color? primaryAlt,
    Color? tint,
    Color? tintStrong,
    Color? borderGlow,
    Color? borderAccent,
    Color? bgTinted,
    Color? bgWarm,
    Color? accentOrange,
    Color? surfaceBright,
    Color? onSurfaceBright,
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? backgroundSurface,
    Color? backgroundElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textFaint,
    Color? textMuted,
    Color? textQuiet,
    Color? textDim,
    Color? textSubtle,
    Color? surfaceTranslucent,
    Color? borderSubtle,
    Color? borderMedium,
    Color? destructive,
    Color? destructiveBorder,
    Color? destructiveOutline,
    Color? destructiveTint,
    Color? success,
    Color? warning,
    Color? brandLight,
    Color? onBrandLight,
    Color? glassSurface,
    Color? scrim,
    Color? proteinAccent,
    Color? carbsAccent,
    Color? fatAccent,
    Color? fiberAccent,
    Color? accentOrangeMuted,
    Color? accentOrangeDeep,
    Color? accentOrangeLight,
    Color? amberBorder,
    Color? amberSurface,
    Color? accentViolet,
  }) {
    return AppColorTokens(
      primary: primary ?? this.primary,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      primaryAlt: primaryAlt ?? this.primaryAlt,
      tint: tint ?? this.tint,
      tintStrong: tintStrong ?? this.tintStrong,
      borderGlow: borderGlow ?? this.borderGlow,
      borderAccent: borderAccent ?? this.borderAccent,
      bgTinted: bgTinted ?? this.bgTinted,
      bgWarm: bgWarm ?? this.bgWarm,
      accentOrange: accentOrange ?? this.accentOrange,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      onSurfaceBright: onSurfaceBright ?? this.onSurfaceBright,
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundSurface: backgroundSurface ?? this.backgroundSurface,
      backgroundElevated: backgroundElevated ?? this.backgroundElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textFaint: textFaint ?? this.textFaint,
      textMuted: textMuted ?? this.textMuted,
      textQuiet: textQuiet ?? this.textQuiet,
      textDim: textDim ?? this.textDim,
      textSubtle: textSubtle ?? this.textSubtle,
      surfaceTranslucent: surfaceTranslucent ?? this.surfaceTranslucent,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderMedium: borderMedium ?? this.borderMedium,
      destructive: destructive ?? this.destructive,
      destructiveBorder: destructiveBorder ?? this.destructiveBorder,
      destructiveOutline: destructiveOutline ?? this.destructiveOutline,
      destructiveTint: destructiveTint ?? this.destructiveTint,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      brandLight: brandLight ?? this.brandLight,
      onBrandLight: onBrandLight ?? this.onBrandLight,
      glassSurface: glassSurface ?? this.glassSurface,
      scrim: scrim ?? this.scrim,
      proteinAccent: proteinAccent ?? this.proteinAccent,
      carbsAccent: carbsAccent ?? this.carbsAccent,
      fatAccent: fatAccent ?? this.fatAccent,
      fiberAccent: fiberAccent ?? this.fiberAccent,
      accentOrangeMuted: accentOrangeMuted ?? this.accentOrangeMuted,
      accentOrangeDeep: accentOrangeDeep ?? this.accentOrangeDeep,
      accentOrangeLight: accentOrangeLight ?? this.accentOrangeLight,
      amberBorder: amberBorder ?? this.amberBorder,
      amberSurface: amberSurface ?? this.amberSurface,
      accentViolet: accentViolet ?? this.accentViolet,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t)!,
      primaryAlt: Color.lerp(primaryAlt, other.primaryAlt, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      tintStrong: Color.lerp(tintStrong, other.tintStrong, t)!,
      borderGlow: Color.lerp(borderGlow, other.borderGlow, t)!,
      borderAccent: Color.lerp(borderAccent, other.borderAccent, t)!,
      bgTinted: Color.lerp(bgTinted, other.bgTinted, t)!,
      bgWarm: Color.lerp(bgWarm, other.bgWarm, t)!,
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      onSurfaceBright: Color.lerp(onSurfaceBright, other.onSurfaceBright, t)!,
      backgroundPrimary: Color.lerp(
        backgroundPrimary,
        other.backgroundPrimary,
        t,
      )!,
      backgroundSecondary: Color.lerp(
        backgroundSecondary,
        other.backgroundSecondary,
        t,
      )!,
      backgroundSurface: Color.lerp(
        backgroundSurface,
        other.backgroundSurface,
        t,
      )!,
      backgroundElevated: Color.lerp(
        backgroundElevated,
        other.backgroundElevated,
        t,
      )!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textQuiet: Color.lerp(textQuiet, other.textQuiet, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      textSubtle: Color.lerp(textSubtle, other.textSubtle, t)!,
      surfaceTranslucent: Color.lerp(
        surfaceTranslucent,
        other.surfaceTranslucent,
        t,
      )!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderMedium: Color.lerp(borderMedium, other.borderMedium, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      destructiveBorder: Color.lerp(
        destructiveBorder,
        other.destructiveBorder,
        t,
      )!,
      destructiveOutline: Color.lerp(
        destructiveOutline,
        other.destructiveOutline,
        t,
      )!,
      destructiveTint: Color.lerp(destructiveTint, other.destructiveTint, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      brandLight: Color.lerp(brandLight, other.brandLight, t)!,
      onBrandLight: Color.lerp(onBrandLight, other.onBrandLight, t)!,
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      proteinAccent: Color.lerp(proteinAccent, other.proteinAccent, t)!,
      carbsAccent: Color.lerp(carbsAccent, other.carbsAccent, t)!,
      fatAccent: Color.lerp(fatAccent, other.fatAccent, t)!,
      fiberAccent: Color.lerp(fiberAccent, other.fiberAccent, t)!,
      accentOrangeMuted: Color.lerp(
        accentOrangeMuted,
        other.accentOrangeMuted,
        t,
      )!,
      accentOrangeDeep: Color.lerp(
        accentOrangeDeep,
        other.accentOrangeDeep,
        t,
      )!,
      accentOrangeLight: Color.lerp(
        accentOrangeLight,
        other.accentOrangeLight,
        t,
      )!,
      amberBorder: Color.lerp(amberBorder, other.amberBorder, t)!,
      amberSurface: Color.lerp(amberSurface, other.amberSurface, t)!,
      accentViolet: Color.lerp(accentViolet, other.accentViolet, t)!,
    );
  }
}

@immutable
class AppGradientTokens extends ThemeExtension<AppGradientTokens> {
  const AppGradientTokens({
    required this.primaryButton,
    required this.primary,
    required this.bright,
    required this.ramp,
    required this.full,
    required this.barFill,
    required this.darkGlow,
    required this.reversed,
    required this.amber,
    required this.subtle,
    required this.orange,
    required this.glowRadial,
    required this.mainBackground,
    required this.innerBackground,
    required this.glowCard,
    required this.chartArea,
    required this.shareSheen,
    this.macroProtein = _MacroGradients.protein,
    this.macroCarbs = _MacroGradients.carbs,
    this.macroFats = _MacroGradients.fats,
    this.cameraScrim = _OverlayGradients.cameraScrim,
    this.cardSheen = _OverlayGradients.cardSheen,
    this.actionScrim = _OverlayGradients.actionScrim,
  });

  final Gradient primaryButton;
  final Gradient primary;
  final Gradient bright;
  final Gradient ramp;
  final Gradient full;
  final Gradient barFill;
  final Gradient darkGlow;
  final Gradient reversed;
  final Gradient amber;
  final Gradient subtle;
  final Gradient orange;
  final Gradient glowRadial;
  final Gradient mainBackground;
  final Gradient innerBackground;
  final Gradient glowCard;
  final Gradient chartArea;
  final Gradient shareSheen;
  final Gradient macroProtein;
  final Gradient macroCarbs;
  final Gradient macroFats;
  final Gradient cameraScrim;
  final Gradient cardSheen;
  final Gradient actionScrim;

  static const defaultBackground = LinearGradient(
    colors: [Color(0xFF14110B), _AppPalette.backgroundPrimary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const flow = AppGradientTokens(
    primaryButton: LinearGradient(
      colors: [Color(0xFFC3FF3D), Color(0xFFC3FF3D), Color(0xFF87B26B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    ),
    primary: LinearGradient(colors: [Color(0xFFC3FF3D), Color(0xFF87B26B)]),
    bright: LinearGradient(colors: [Color(0xFFC3FF3D), Color(0xFFA9F500)]),
    ramp: LinearGradient(colors: [Color(0xFF84CC16), Color(0xFFC3FF3D)]),
    full: LinearGradient(
      colors: [Color(0xFF84B814), Color(0xFFC3FF3D), Color(0xFFFFFFFF)],
    ),
    barFill: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFC3FF3D), Color(0xFF84B814)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    ),
    darkGlow: LinearGradient(
      colors: [Color(0xFF1C2218), Color(0xFF93D500)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    reversed: LinearGradient(colors: [Color(0xFF87B26B), Color(0xFFC3FF3D)]),
    amber: LinearGradient(colors: [Color(0xFFF97316), Color(0xFFF59E0B)]),
    subtle: LinearGradient(colors: [Color(0xFFC3FF3D), Color(0xFFC3FF3D)]),
    orange: LinearGradient(colors: [Color(0xFFD55900), Color(0xFFF97316)]),
    glowRadial: RadialGradient(
      colors: [Color(0x17C3FF3D), Color(0xFF000000)],
      stops: [0, 0.7],
    ),
    mainBackground: LinearGradient(
      colors: [Color(0x26C3FF3D), Color(0xFF1F2218), Color(0xFF0A0A0A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    ),
    innerBackground: LinearGradient(
      colors: [Color(0x26C3FF3D), Color(0xFF1F2218), Color(0x2687B26B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    ),
    glowCard: LinearGradient(
      colors: [_AppPalette.backgroundSurface, Color(0xFF55722A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.3, 1.0],
    ),
    chartArea: LinearGradient(
      colors: [Color(0x59C3FF3D), Color(0x00C3FF3D)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    shareSheen: LinearGradient(
      colors: [
        Color(0xFF1C2609),
        Color(0xFF47690C),
        Color(0xFFA9D63F),
        Color(0xFF3E5A11),
        Color(0xFF16200D),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.32, 0.5, 0.68, 1.0],
    ),
  );

  static const steady = AppGradientTokens(
    primaryButton: LinearGradient(
      colors: [Color(0xFFF97316), Color(0xFFF97316), Color(0xFFD55900)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    ),
    primary: LinearGradient(colors: [Color(0xFFF97316), Color(0xFFD55900)]),
    bright: LinearGradient(colors: [Color(0xFFF97316), Color(0xFFF97316)]),
    ramp: LinearGradient(colors: [Color(0xFFF97316), Color(0xFFF97316)]),
    full: LinearGradient(colors: [Color(0xFFF97316), Color(0xFFF97316)]),
    barFill: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFF97316), Color(0xFFD55900)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    ),
    darkGlow: LinearGradient(
      colors: [Color(0xFF221C18), Color(0xFFD55900)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    reversed: LinearGradient(colors: [Color(0xFFD55900), Color(0xFFF97316)]),
    amber: LinearGradient(colors: [Color(0xFFF97316), Color(0xFFF59E0B)]),
    subtle: LinearGradient(colors: [Color(0xFFF97316), Color(0xFFF97316)]),
    orange: LinearGradient(colors: [Color(0xFFD55900), Color(0xFFF97316)]),
    glowRadial: RadialGradient(
      colors: [Color(0x17F97316), Color(0xFF000000)],
      stops: [0, 0.7],
    ),
    mainBackground: LinearGradient(
      colors: [Color(0x26F97316), Color(0xFF221C18), Color(0xFF0A0A0A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    ),
    innerBackground: LinearGradient(
      colors: [Color(0x26F97316), Color(0xFF221C18), Color(0x26D55900)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    ),
    glowCard: LinearGradient(
      colors: [_AppPalette.backgroundSurface, Color(0xFF7A4418)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.3, 1.0],
    ),
    chartArea: LinearGradient(
      colors: [Color(0x59F97316), Color(0x00F97316)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    shareSheen: LinearGradient(
      colors: [
        Color(0xFF261807),
        Color(0xFF6B3A0A),
        Color(0xFFF0A24A),
        Color(0xFF5B330C),
        Color(0xFF201405),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.32, 0.5, 0.68, 1.0],
    ),
  );

  static const restore = AppGradientTokens(
    primaryButton: LinearGradient(
      colors: [Color(0xFF28D5E6), Color(0xFF28D5E6), Color(0xFF00C4D5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    ),
    primary: LinearGradient(colors: [Color(0xFF28D5E6), Color(0xFF00C4D5)]),
    bright: LinearGradient(colors: [Color(0xFF28D5E6), Color(0xFF28D5E6)]),
    ramp: LinearGradient(colors: [Color(0xFF28D5E6), Color(0xFF28D5E6)]),
    full: LinearGradient(colors: [Color(0xFF28D5E6), Color(0xFF28D5E6)]),
    barFill: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFF28D5E6), Color(0xFF00C4D5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    ),
    darkGlow: LinearGradient(
      colors: [Color(0xFF182122), Color(0xFF00C4D5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    reversed: LinearGradient(colors: [Color(0xFF00C4D5), Color(0xFF28D5E6)]),
    amber: LinearGradient(colors: [Color(0xFFF97316), Color(0xFFF59E0B)]),
    subtle: LinearGradient(colors: [Color(0xFF28D5E6), Color(0xFF22CDE6)]),
    orange: LinearGradient(colors: [Color(0xFFD55900), Color(0xFFF97316)]),
    glowRadial: RadialGradient(
      colors: [Color(0x1728D5E6), Color(0xFF000000)],
      stops: [0, 0.7],
    ),
    mainBackground: LinearGradient(
      colors: [Color(0x2628D5E6), Color(0xFF182122), Color(0xFF0A0A0A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    ),
    innerBackground: LinearGradient(
      colors: [Color(0x2628D5E6), Color(0xFF182122), Color(0x2600C4D5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    ),
    glowCard: LinearGradient(
      colors: [_AppPalette.backgroundSurface, Color(0xFF1F6670)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.3, 1.0],
    ),
    chartArea: LinearGradient(
      colors: [Color(0x5928D5E6), Color(0x0028D5E6)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    shareSheen: LinearGradient(
      colors: [
        Color(0xFF071E24),
        Color(0xFF0A5C6B),
        Color(0xFF4FD3E6),
        Color(0xFF0B4D5A),
        Color(0xFF06181D),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.32, 0.5, 0.68, 1.0],
    ),
  );

  @override
  AppGradientTokens copyWith({
    Gradient? primaryButton,
    Gradient? primary,
    Gradient? bright,
    Gradient? ramp,
    Gradient? full,
    Gradient? barFill,
    Gradient? darkGlow,
    Gradient? reversed,
    Gradient? amber,
    Gradient? subtle,
    Gradient? orange,
    Gradient? glowRadial,
    Gradient? mainBackground,
    Gradient? innerBackground,
    Gradient? glowCard,
    Gradient? chartArea,
    Gradient? shareSheen,
    Gradient? macroProtein,
    Gradient? macroCarbs,
    Gradient? macroFats,
    Gradient? cameraScrim,
    Gradient? cardSheen,
    Gradient? actionScrim,
  }) {
    return AppGradientTokens(
      primaryButton: primaryButton ?? this.primaryButton,
      primary: primary ?? this.primary,
      bright: bright ?? this.bright,
      ramp: ramp ?? this.ramp,
      full: full ?? this.full,
      barFill: barFill ?? this.barFill,
      darkGlow: darkGlow ?? this.darkGlow,
      reversed: reversed ?? this.reversed,
      amber: amber ?? this.amber,
      subtle: subtle ?? this.subtle,
      orange: orange ?? this.orange,
      glowRadial: glowRadial ?? this.glowRadial,
      mainBackground: mainBackground ?? this.mainBackground,
      innerBackground: innerBackground ?? this.innerBackground,
      glowCard: glowCard ?? this.glowCard,
      chartArea: chartArea ?? this.chartArea,
      shareSheen: shareSheen ?? this.shareSheen,
      macroProtein: macroProtein ?? this.macroProtein,
      macroCarbs: macroCarbs ?? this.macroCarbs,
      macroFats: macroFats ?? this.macroFats,
      cameraScrim: cameraScrim ?? this.cameraScrim,
      cardSheen: cardSheen ?? this.cardSheen,
      actionScrim: actionScrim ?? this.actionScrim,
    );
  }

  @override
  AppGradientTokens lerp(ThemeExtension<AppGradientTokens>? other, double t) {
    if (other is! AppGradientTokens) return this;
    return AppGradientTokens(
      primaryButton: Gradient.lerp(primaryButton, other.primaryButton, t)!,
      primary: Gradient.lerp(primary, other.primary, t)!,
      bright: Gradient.lerp(bright, other.bright, t)!,
      ramp: Gradient.lerp(ramp, other.ramp, t)!,
      full: Gradient.lerp(full, other.full, t)!,
      barFill: Gradient.lerp(barFill, other.barFill, t)!,
      darkGlow: Gradient.lerp(darkGlow, other.darkGlow, t)!,
      reversed: Gradient.lerp(reversed, other.reversed, t)!,
      amber: Gradient.lerp(amber, other.amber, t)!,
      subtle: Gradient.lerp(subtle, other.subtle, t)!,
      orange: Gradient.lerp(orange, other.orange, t)!,
      glowRadial: Gradient.lerp(glowRadial, other.glowRadial, t)!,
      mainBackground: Gradient.lerp(mainBackground, other.mainBackground, t)!,
      innerBackground: Gradient.lerp(innerBackground, other.innerBackground, t)!,
      glowCard: Gradient.lerp(glowCard, other.glowCard, t)!,
      chartArea: Gradient.lerp(chartArea, other.chartArea, t)!,
      shareSheen: Gradient.lerp(shareSheen, other.shareSheen, t)!,
      macroProtein: Gradient.lerp(macroProtein, other.macroProtein, t)!,
      macroCarbs: Gradient.lerp(macroCarbs, other.macroCarbs, t)!,
      macroFats: Gradient.lerp(macroFats, other.macroFats, t)!,
      cameraScrim: Gradient.lerp(cameraScrim, other.cameraScrim, t)!,
      cardSheen: Gradient.lerp(cardSheen, other.cardSheen, t)!,
      actionScrim: Gradient.lerp(actionScrim, other.actionScrim, t)!,
    );
  }
}
