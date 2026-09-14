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

  static const TextStyle bodyXSmallSemiBold = TextStyle(
    fontFamily: _fontBody,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle bodyXSmallMedium = TextStyle(
    fontFamily: _fontBody,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0,
  );
}
