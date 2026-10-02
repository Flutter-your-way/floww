import 'package:flutter/animation.dart';

import 'package:floww/config/constants/app_sizes.dart';

class AppMotion {
  AppMotion._();

  static const Duration press = Duration(milliseconds: 120);
  static const Duration expand = Duration(milliseconds: 280);
  static const Duration expandSoft = Duration(milliseconds: 460);
  static const Duration fast = Duration(milliseconds: 480);
  static const Duration medium = Duration(milliseconds: 720);
  static const Duration modeShift = Duration(milliseconds: 900);
  static const Duration notice = Duration(milliseconds: 4000);
  static const Duration profileAnalysis = Duration(milliseconds: 5600);
  static const Duration analysisScreen = Duration(milliseconds: 640);
  static const Duration analysisStep = Duration(milliseconds: 420);
  static const Curve analysisCurve = Curves.easeOutCubic;
  static const Interval analysisTitleIn = Interval(
    0.08,
    0.2,
    curve: Curves.easeOutCubic,
  );
  static const double analysisStepsStart = 0.16;
  static const double analysisStepsEnd = 0.9;
  static const double analysisStepRevealSpan = 0.1;
  static const double analysisStepRevealStagger = 0.03;
  static const double analysisRise = AppSizes.s12;
  static const double analysisExitScale = 1.04;

  static const Duration permissionPromptDelay = Duration(milliseconds: 900);

  static const Duration blueprintScore = Duration(milliseconds: 1600);
  static const Duration blueprintScoreDelay = Duration(milliseconds: 420);
  static const Curve blueprintScoreCurve = Curves.easeOutCubic;

  static const Curve enter = Curves.easeOutQuart;
  static const Curve expandCurve = Curves.easeOutCubic;
  static const Curve collapseCurve = Curves.easeInCubic;
  static const double pressScale = 0.98;
  static const double halfTurn = 0.5;
  static const double quarterTurn = 0.25;
  static const Curve pop = Curves.easeOutBack;
  static const Curve fadeIn = Interval(0, 0.6, curve: Curves.easeOut);

  static const double slideDistance = AppSizes.s32;
  static const double slideDistanceSmall = AppSizes.s12;
  static const double slideDistanceTab = AppSizes.s24;

  static const Duration stepper = Duration(milliseconds: 260);
  static const Curve stepperCurve = Cubic(0.2, 1, 0.3, 1);
  static const Curve stepperExitCurve = Curves.easeIn;
  static const double stepperSlide = 0.6;
  static const double stepperScale = 0.88;
  static const double stepperPressScale = 0.86;
  static const Duration stepperRepeat = Duration(milliseconds: 90);

  static const Duration segment = Duration(milliseconds: 460);
  static const Duration segmentLabel = Duration(milliseconds: 320);
  static const Curve segmentCurve = Cubic(0.2, 1, 0.3, 1);
  static const double segmentStretch = 0.14;
  static const double segmentSquash = 0.5;

  static const Duration composerGrow = Duration(milliseconds: 240);
  static const Curve composerGrowCurve = Cubic(0.2, 1, 0.3, 1);

  static const Duration waveTyping = Duration(milliseconds: 1100);
  static const double waveTypingMinOpacity = 0.25;
  static const double waveTypingStagger = 0.18;

  static const Duration tabSwitch = Duration(milliseconds: 420);
  static const Curve tabSwitchCurve = Curves.easeOutCubic;
  static const Curve tabSwitchExitCurve = Curves.easeInCubic;
  static const Curve tabSwitchSizeCurve = Curves.easeInOutCubic;
  static const Interval tabSwitchFadeIn = Interval(
    0.32,
    1,
    curve: Curves.easeOut,
  );
  static const Interval tabSwitchFadeOut = Interval(
    0,
    0.42,
    curve: Curves.easeIn,
  );
  static const double tabSwitchScale = 0.97;

  static const Duration popReveal = Duration(milliseconds: 560);
  static const Interval popRevealSize = Interval(
    0,
    0.55,
    curve: Curves.easeInOutCubic,
  );
  static const Interval popRevealScaleIn = Interval(
    0,
    1,
    curve: Curves.easeOutBack,
  );
  static const Interval popRevealScaleOut = Interval(
    0.55,
    1,
    curve: Curves.easeOutCubic,
  );
  static const Interval popRevealFadeIn = Interval(
    0,
    0.5,
    curve: Curves.easeOut,
  );
  static const Interval popRevealFadeOut = Interval(
    0.55,
    1,
    curve: Curves.easeOut,
  );
  static const double popRevealScale = 0.9;

  static const Duration staggerReveal = Duration(milliseconds: 1400);
  static const double staggerRevealStep = 0.09;
  static const double staggerRevealSpan = 0.4;

  static const Duration tabReveal = Duration(milliseconds: 260);
  static const Curve tabRevealCurve = Curves.easeOutCubic;

  static const Duration workoutFinishMin = Duration(milliseconds: 1800);
  static const Duration workoutFinishHold = Duration(milliseconds: 1100);
  static const Duration workoutFinishPulse = Duration(milliseconds: 900);
  static const double workoutFinishRowStep = 0.14;
  static const double workoutFinishRowSpan = 0.42;
  static const double workoutFinishLoadingFill = 0.86;
  static const double workoutFinishRowRise = 0.4;

  static const Duration goalChartReveal = Duration(milliseconds: 1100);
  static const Duration goalChartMorph = Duration(milliseconds: 420);
  static const Duration goalDotPulse = Duration(milliseconds: 1600);
  static const Curve goalChartCurve = Curves.easeOutCubic;
  static const Interval goalChartBubbleIn = Interval(
    0.7,
    1,
    curve: Curves.easeOut,
  );

  static const Duration spinnerReveal = Duration(milliseconds: 220);
  static const Duration spinnerRevealDelay = Duration(milliseconds: 120);
  static const Curve spinnerRevealCurve = Curves.easeOut;

  static const Duration placeholderPulse = Duration(milliseconds: 900);
  static const Curve placeholderPulseCurve = Curves.easeInOut;
  static const Duration imageReveal = Duration(milliseconds: 240);
  static const Curve imageRevealCurve = Curves.easeOut;

  static const Duration modeTransitionReduced = Duration(milliseconds: 900);
  static const Duration modeSettleDebounce = Duration(milliseconds: 250);
  static const Duration modeSettleRetry = Duration(milliseconds: 200);
  static const Duration modeBaselineQuiet = Duration(milliseconds: 2500);
  static const Duration modeTransitionCooldown = Duration.zero;
  static const Duration modeTransitionWatchdog = Duration(seconds: 12);
  static const Duration modeHold = Duration(seconds: 5);

  static const Curve modeImmerse = Curves.easeOutCubic;
  static const Curve modeRelease = Curves.easeInOutCubic;
  static const Curve modeBurst = Curves.easeOutExpo;

  static const Interval modeVeilIn = Interval(0, 0.12, curve: modeImmerse);
  static const Interval modeVeilOut = Interval(0.82, 1, curve: modeRelease);
  static const Interval modeContentOut = Interval(
    0.72,
    0.86,
    curve: Curves.easeIn,
  );
  static const Interval modeVisual = Interval(0.06, 0.74, curve: Curves.linear);
  static const Interval modeTitleIn = Interval(0.34, 0.6, curve: modeImmerse);
  static const Interval modeMessageIn = Interval(0.44, 0.7, curve: modeImmerse);
  static const Interval modeActionIn = Interval(0.56, 0.72, curve: modeImmerse);
  static const double modeHoldPoint = 0.72;
  static const double modeThemeSwitchPoint = 0.62;
  static const double modeVeilOpacity = 0.96;
  static const double modeVeilBlurSigma = AppSizes.s18;
  static const double modeCopyRise = AppSizes.s12;
  static const double modeCopyScale = 0.94;
  static const double modeReleaseScale = 1.06;
}
