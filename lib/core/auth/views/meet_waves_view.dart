import 'dart:ui' as ui;

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/custom_button.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/core/auth/widgets/animated_reverse_ripple.dart';
import 'package:floww/core/auth/widgets/custom_mode_card.dart';
import 'package:floww/core/auth/widgets/mode_detail_reveal.dart';
import 'package:floww/core/auth/widgets/step_reveal_item.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:floww/config/theme/app_shapes.dart';

Animation<double> _staggeredPresence(
  AnimationController controller, {
  required double windowStart,
  required int index,
  required int count,
  required bool exit,
}) {
  const windowSize = 0.5;
  const itemSpan = 0.14;
  final perItem = count > 1 ? (windowSize - itemSpan) / (count - 1) : 0.0;
  final start = windowStart + index * perItem;
  final end = start + itemSpan;
  final curved = CurvedAnimation(
    parent: controller,
    curve: Interval(start, end, curve: Curves.easeInOut),
  );
  return exit ? Tween<double>(begin: 1.0, end: 0.0).animate(curved) : curved;
}

class MeetWavesView extends StatefulWidget {
  const MeetWavesView({super.key});

  @override
  State<MeetWavesView> createState() => _MeetWavesViewState();
}

class _MeetWavesViewState extends State<MeetWavesView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stepController;
  late final List<Animation<double>> _stepOnePresence;
  late final List<Animation<double>> _stepTwoPresence;
  final ValueNotifier<Color> _designTint = ValueNotifier(
    AppColorTokens.flow.primary,
  );

  @override
  void initState() {
    super.initState();
    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1840),
    );
    _stepOnePresence = List.generate(
      6,
      (i) => _staggeredPresence(
        _stepController,
        windowStart: 0.0,
        index: i,
        count: 6,
        exit: true,
      ),
    );
    _stepTwoPresence = List.generate(
      3,
      (i) => _staggeredPresence(
        _stepController,
        windowStart: 0.5,
        index: i,
        count: 3,
        exit: false,
      ),
    );
  }

  @override
  void dispose() {
    _stepController.dispose();
    _designTint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundPrimary,
      body: AnimatedBuilder(
        animation: _stepController,
        builder: (context, _) {
          final showingStepTwo = _stepController.value >= 0.5;
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: _MeetWavesBackground(tint: _designTint)),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: showingStepTwo,
                  child: _StepOneContent(
                    presence: _stepOnePresence,
                    onGetStarted: () => _stepController.forward(),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !showingStepTwo,
                  child: _StepTwoContent(
                    presence: _stepTwoPresence,
                    designTint: _designTint,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StepOneContent extends StatelessWidget {
  const _StepOneContent({required this.presence, required this.onGetStarted});

  final List<Animation<double>> presence;
  final VoidCallback onGetStarted;

  Animation<double> _presence(int index) => presence[index];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    children: [
                      StepRevealItem(
                        presence: _presence(0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(AppImages.appIconSvg),
                            SizedBox(width: 8),
                            Text(
                              "Floww",
                              style: context.textTheme.displaySmall,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      StepRevealItem(
                        presence: _presence(1),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            height: 300,
                            width: 300,
                            child: AnimatedReverseRipple(
                              duration: const Duration(milliseconds: 5000),
                              isInward: false,
                              ringCount: 5,
                              rippleColor: AppColorTokens.flow.primary,
                              minRadius: 30.0,
                              maxRadius: 200.0,
                              strokeWidth: 0.5,
                              child: Image.asset(AppImages.ofb),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      StepRevealItem(
                        presence: _presence(2),
                        child: Text(
                          "Powered by AI",
                          style: context.textTheme.displaySmall?.copyWith(
                            color: Colors.white30,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      StepRevealItem(
                        presence: _presence(3),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Meet WAVE",
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: ".",
                                  style: TextStyle(
                                    color: AppColorTokens.flow.primary,
                                  ),
                                ),
                              ],
                            ),
                            style: context.textTheme.displayLarge?.copyWith(
                              fontSize: 58,
                              fontStyle: FontStyle.italic,
                              letterSpacing: -0.15,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      StepRevealItem(
                        presence: _presence(4),
                        child: Text(
                          "A new kind of AI fitness coach — built around how you actually feel, every single day.",
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: Colors.white30,
                            fontFamily: 'PlusJakartaSans',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 68),
                      StepRevealItem(
                        presence: _presence(5),
                        child: GestureDetector(
                          onTap: onGetStarted,
                          child: Container(
                            height: 68,
                            width: MediaQuery.sizeOf(context).width * 0.6,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.xl,
                              horizontal: AppSpacing.xl4,
                            ),
                            decoration: AppShapes.decoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 4,
                                children: [
                                  Text(
                                    "Get Started",
                                    style: context.textTheme.displaySmall,
                                  ),
                                  const Icon(Icons.arrow_forward, size: 30),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModeInfo {
  const _ModeInfo({
    required this.iconPath,
    required this.title,
    required this.description,
    required this.color,
  });

  final String iconPath;
  final String title;
  final String description;
  final Color color;
}

enum _StepTwoPhase { intro, carousel, cardsRecap }

class _StepTwoContent extends StatefulWidget {
  const _StepTwoContent({required this.presence, required this.designTint});

  final List<Animation<double>> presence;
  final ValueNotifier<Color> designTint;

  @override
  State<_StepTwoContent> createState() => _StepTwoContentState();
}

class _StepTwoContentState extends State<_StepTwoContent> {
  static const Color _steadyAccent = Color(0xFFFF9F43);
  static const Color _restoreAccent = Color(0xFF18D8F0);
  static const Color _mutedText = Color(0xFF919191);

  static final List<_ModeInfo> _modes = [
    _ModeInfo(
      iconPath: AppImages.welcome1,
      title: 'FLOW',
      description:
          "Peak performance. You're recovered, energized, and ready to push hard.",
      color: AppColorTokens.flow.primary,
    ),
    const _ModeInfo(
      iconPath: AppImages.welcome2,
      title: 'STEADY',
      description:
          'Consistent progress. Moderate intensity, building the habit long-term.',
      color: _steadyAccent,
    ),
    const _ModeInfo(
      iconPath: AppImages.welcome3,
      title: 'RESTORE',
      description:
          'Recovery day. Light movement, mobility, and letting your body rebuild.',
      color: _restoreAccent,
    ),
  ];

  _StepTwoPhase _phase = _StepTwoPhase.intro;
  int _modeIndex = 0;
  bool _descriptionTyped = false;
  int _cardStage = 0;

  Animation<double> get _introTrigger => widget.presence[2];

  @override
  void initState() {
    super.initState();
    if (_introTrigger.value >= 1.0) {
      _enterCarousel();
    } else {
      _introTrigger.addListener(_onIntroTick);
    }
  }

  void _onIntroTick() {
    if (_introTrigger.value >= 1.0) {
      _introTrigger.removeListener(_onIntroTick);
      setState(_enterCarousel);
    }
  }

  void _enterCarousel() {
    _phase = _StepTwoPhase.carousel;
    _modeIndex = 0;
    widget.designTint.value = _modes[0].color;
  }

  void _onContinue() {
    if (_modeIndex < _modes.length - 1) {
      setState(() {
        _modeIndex++;
        _descriptionTyped = false;
      });
      widget.designTint.value = _modes[_modeIndex].color;
    } else {
      setState(() {
        _phase = _StepTwoPhase.cardsRecap;
        _cardStage = 1;
      });
      widget.designTint.value = AppColorTokens.flow.primary;
    }
  }

  void _advanceStage(int next) {
    if (_cardStage < next) setState(() => _cardStage = next);
  }

  @override
  void dispose() {
    _introTrigger.removeListener(_onIntroTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final buttonVisible = switch (_phase) {
      _StepTwoPhase.carousel => _descriptionTyped,
      _StepTwoPhase.cardsRecap => _cardStage >= 4,
      _StepTwoPhase.intro => false,
    };
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    children: [
                      StepRevealItem(
                        presence: widget.presence[0],
                        child: const CustomHeader(title: "Welcome to Floww"),
                      ),
                      SizedBox(height: height * 0.06),
                      StepRevealItem(
                        presence: widget.presence[1],
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Three Modes. \nOne System.",
                            style: context.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      StepRevealItem(
                        presence: widget.presence[2],
                        child: Text(
                          "WAVE adapts your workouts and nutrition\n every day based on how you feel.",
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: _mutedText,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSizes.s28),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 420),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.85,
                              end: 1.0,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: switch (_phase) {
                          _StepTwoPhase.carousel => ModeDetailReveal(
                            key: ValueKey('mode-$_modeIndex'),
                            iconPath: _modes[_modeIndex].iconPath,
                            title: _modes[_modeIndex].title,
                            description: _modes[_modeIndex].description,
                            color: _modes[_modeIndex].color,
                            onRevealed: () =>
                                setState(() => _descriptionTyped = true),
                          ),
                          _StepTwoPhase.cardsRecap => Column(
                            key: const ValueKey('cards-recap'),
                            children: [
                              for (var i = 0; i < _modes.length; i++) ...[
                                if (i > 0) const SizedBox(height: 16),
                                CustomModeCard(
                                  iconPath: _modes[i].iconPath,
                                  title: _modes[i].title,
                                  description: _modes[i].description,
                                  color: _modes[i].color,
                                  visible: _cardStage >= i + 1,
                                  onRevealed: () => _advanceStage(i + 2),
                                ),
                              ],
                            ],
                          ),
                          _StepTwoPhase.intro => const SizedBox.shrink(
                            key: ValueKey('empty'),
                          ),
                        },
                      ),
                      const Spacer(),
                      AnimatedScale(
                        scale: buttonVisible ? 1.0 : 0.85,
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutBack,
                        child: AnimatedOpacity(
                          opacity: buttonVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 320),
                          child: IgnorePointer(
                            ignoring: !buttonVisible,
                            child: CustomButton(
                              text: _phase == _StepTwoPhase.carousel
                                  ? "Continue"
                                  : "Let's personalize",
                              backgroundColor: _phase == _StepTwoPhase.carousel
                                  ? _modes[_modeIndex].color
                                  : null,
                              onPressed: _phase == _StepTwoPhase.carousel
                                  ? _onContinue
                                  : () {
                                      NavigationService.instance.push(
                                        AppRouter.accountSetup,
                                      );
                                    },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.paddingOf(context).bottom),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MeetWavesBackground extends StatelessWidget {
  const _MeetWavesBackground({required this.tint});

  final ValueNotifier<Color> tint;

  static const double designWidth = 375.0;
  static const double designHeight = 812.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.center,
          child: SizedBox(
            width: designWidth,
            height: designHeight,
            child: _MeetWavesDesign(tint: tint),
          ),
        );
      },
    );
  }
}

class _MeetWavesDesign extends StatelessWidget {
  const _MeetWavesDesign({required this.tint});

  final ValueNotifier<Color> tint;

  static const double designHeight = _MeetWavesBackground.designHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppGradientTokens.defaultBackground,
            ),
          ),
        ),
        Positioned.fill(
          child: ValueListenableBuilder<Color>(
            valueListenable: tint,
            builder: (context, color, _) => _LivingGlowOverlay(color: color),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: designHeight * 0.4,
          child: ValueListenableBuilder<Color>(
            valueListenable: tint,
            builder: (context, color, _) => _BottomGlow(color: color),
          ),
        ),
      ],
    );
  }
}

class _LivingGlowOverlay extends StatefulWidget {
  const _LivingGlowOverlay({required this.color});

  final Color color;

  @override
  State<_LivingGlowOverlay> createState() => _LivingGlowOverlayState();
}

class _LivingGlowOverlayState extends State<_LivingGlowOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: widget.color),
      duration: const Duration(milliseconds: 600),
      builder: (context, animatedColor, _) {
        return AnimatedBuilder(
          animation: _breathController,
          builder: (context, _) {
            final t = _breathController.value;
            final begin = Alignment.lerp(
              const Alignment(-1.0, -1.0),
              const Alignment(-1.0, -0.9),
              t,
            )!;
            final opacity = ui.lerpDouble(0.14, 0.26, t)!;
            return Opacity(
              opacity: opacity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: begin,
                    end: const Alignment(-0.0026667, 0.0),
                    colors: [
                      animatedColor ?? widget.color,
                      const Color(0xFF13100B),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BottomGlow extends StatefulWidget {
  const _BottomGlow({required this.color});

  final Color color;

  @override
  State<_BottomGlow> createState() => _BottomGlowState();
}

class _BottomGlowState extends State<_BottomGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: widget.color),
      duration: const Duration(milliseconds: 600),
      builder: (context, animatedColor, _) {
        return AnimatedBuilder(
          animation: _breathController,
          builder: (context, _) {
            final opacity = ui.lerpDouble(0.22, 0.38, _breathController.value)!;
            return Opacity(
              opacity: opacity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [animatedColor ?? widget.color, Colors.transparent],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
