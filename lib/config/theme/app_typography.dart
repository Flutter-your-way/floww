import 'package:flutter/material.dart';

/// AppTypography defines the exact typography styles based on the design system.
///
/// **Direct Usage:**
/// ```dart
/// Text('Hello World', style: AppTypography.heading1);
/// ```
///
/// **Theme Usage (Recommended):**
/// Since these are mapped in `AppTheme`, you can also use standard theme properties:
/// ```dart
/// Text('Hello World', style: Theme.of(context).textTheme.displayLarge);
/// ```
class AppTypography {
  static const String _fontHeading = 'PlusJakartaSans';
  static const String _fontBody = 'HankenGrotesk';

  static const TextStyle displayNumeric = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 72,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle heading2ExtraBold = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle heading2Bold = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle heading3Bold = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle heading3SemiBold = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle heading3ExtraBoldItalic = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,
    height: 30 / 24,
    letterSpacing: -0.15,
  );

  static const TextStyle heading3Medium = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle heading4 = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle heading4SemiBold = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 28 / 18,
    letterSpacing: 0,
  );

  static const TextStyle bodyLargeBold = TextStyle(
    fontFamily: _fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle bodyLargeSemiBold = TextStyle(
    fontFamily: _fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle bodyLargeSemiBoldTight = TextStyle(
    fontFamily: _fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    letterSpacing: -0.18,
  );

  static const TextStyle bodyLargeSemiBoldTall = TextStyle(
    fontFamily: _fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    letterSpacing: 0,
  );

  static const TextStyle bodyLargeMedium = TextStyle(
    fontFamily: _fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle bodyMediumBold = TextStyle(
    fontFamily: _fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle bodyMediumSemiBold = TextStyle(
    fontFamily: _fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 0,
  );

  static const TextStyle bodyMediumMedium = TextStyle(
    fontFamily: _fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 0,
  );

  static const TextStyle bodyMediumRegular = TextStyle(
    fontFamily: _fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle bodySmallExtraBold = TextStyle(
    fontFamily: _fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle bodySmallSemiBold = TextStyle(
    fontFamily: _fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle bodySmallMedium = TextStyle(
    fontFamily: _fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle bodySmallItalic = TextStyle(
    fontFamily: _fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle bodySmallBoldTight = TextStyle(
    fontFamily: _fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
    letterSpacing: -0.12,
  );

  static const TextStyle bodySmallRegularTight = TextStyle(
    fontFamily: _fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0,
  );

  static const TextStyle bodySmallMediumTight = TextStyle(
    fontFamily: _fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: -0.12,
  );

  static const TextStyle bodyXLargeBold = TextStyle(
    fontFamily: _fontBody,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 24 / 20,
    letterSpacing: 0,
  );

  static const TextStyle bodyXXLargeBold = TextStyle(
    fontFamily: _fontBody,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 48 / 40,
    letterSpacing: -0.3,
  );

  static const TextStyle bodyXXXLargeBold = TextStyle(
    fontFamily: _fontBody,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 58 / 48,
    letterSpacing: -0.4,
  );

  static const TextStyle bodyHeadlineBoldTight = TextStyle(
    fontFamily: _fontBody,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 30 / 24,
    letterSpacing: -0.15,
  );

  static const TextStyle bodyMediumMediumTight = TextStyle(
    fontFamily: _fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: -0.16,
  );

  static const TextStyle bodyXSmallRegular = TextStyle(
    fontFamily: _fontBody,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 12 / 10,
    letterSpacing: 0,
  );

  static const TextStyle captionSemiBold = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 12 / 10,
    letterSpacing: 0,
  );

  static const TextStyle captionMediumSmall = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 12 / 10,
    letterSpacing: 0,
  );

  static const TextStyle captionSemiBoldMicro = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 9,
    fontWeight: FontWeight.w600,
    height: 10 / 9,
    letterSpacing: 0,
  );

  static const TextStyle captionMediumMicro = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 9,
    fontWeight: FontWeight.w500,
    height: 10 / 9,
    letterSpacing: 0,
  );

  static const TextStyle captionMedium = TextStyle(
    fontFamily: _fontBody,
    fontSize: 9,
    fontWeight: FontWeight.w500,
    height: 10 / 9,
    letterSpacing: 0,
  );

  static const TextStyle bodyXSmallSemiBold = TextStyle(
    fontFamily: _fontBody,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle labelSmallSemiBold = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle labelLargeSemiBold = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    letterSpacing: -0.18,
  );

  static const TextStyle labelLargeMedium = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 22 / 16,
    letterSpacing: -0.18,
  );

  static const TextStyle labelMediumSemiBold = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: -0.16,
  );

  static const TextStyle labelMediumRegular = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: -0.16,
  );

  static const TextStyle labelSmallMedium = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: -0.12,
  );

  static const TextStyle labelSmallRegular = TextStyle(
    fontFamily: _fontHeading,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: -0.12,
  );

  static const TextStyle bodyXSmallMedium = TextStyle(
    fontFamily: _fontBody,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0,
  );
}
