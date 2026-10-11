import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/widgets/theme/sheet_theme.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/wave/models/wave_action.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/models/wave_message.dart';
import 'package:floww/core/wave/models/wave_quick_action.dart';
import 'package:floww/core/wave/services/wave_chat_service.dart';
import 'package:floww/core/wave/services/wave_context_service.dart';
import 'package:floww/core/wave/services/wave_transcript_service.dart';
import 'package:floww/core/wave/view_models/wave_chat_view_model.dart';
import 'package:floww/core/wave/widgets/wave_backdrop.dart';
import 'package:floww/core/wave/widgets/wave_chat_header.dart';
import 'package:floww/core/wave/widgets/wave_composer.dart';
import 'package:floww/core/wave/widgets/wave_bottom_fade.dart';
import 'package:floww/core/wave/widgets/wave_quota_banner.dart';
import 'package:floww/core/wave/widgets/wave_size_reporter.dart';
import 'package:floww/core/wave/widgets/wave_quota_meter.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/core/wave/views/wave_history_sheet.dart';
import 'package:floww/core/wave/views/wave_voice_sheet.dart';
import 'package:floww/core/wave/widgets/wave_message_item.dart';
import 'package:floww/core/wave/widgets/wave_message_entrance.dart';
import 'package:floww/core/wave/widgets/wave_thinking_indicator.dart';
import 'package:floww/core/wave/widgets/wave_quick_action_bar.dart';
import 'package:floww/core/wave/widgets/wave_sheet_glow.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';
import 'package:floww/navigation/view_models/main_tab_controller.dart';

Future<void> showWaveChatSheet(BuildContext context) {
  final forcedMode = SheetTheme.forcedModeOf(context);
  final tabs = context.read<MainTabController?>();

  return Navigator.of(context).push(
    _WaveSheetRoute(
      forcedMode: forcedMode,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      child: WaveChatSheet(tabs: tabs),
    ),
  );
}

class _WaveSheetRoute extends PopupRoute<void> {
  _WaveSheetRoute({
    required this.forcedMode,
    required this.barrierLabel,
    required this.child,
  });

  final AppThemeMode? forcedMode;
  final Widget child;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => AppMotion.waveSheetOpen;

  @override
  Duration get reverseTransitionDuration => AppMotion.waveSheetClose;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => SheetTheme(forcedMode: forcedMode, child: child);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.waveSheetOpenCurve,
      reverseCurve: AppMotion.waveSheetCloseCurve,
    );

    return SheetTheme(
      forcedMode: forcedMode,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: FadeTransition(
              opacity: animation,
              child: const WaveBackdrop(blur: false),
            ),
          ),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: AppMotion.waveSheetOpenScale,
                end: 1,
              ).animate(curved),
              alignment: Alignment.bottomCenter,
              child: RepaintBoundary(child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveChatSheet extends StatelessWidget {
  const WaveChatSheet({super.key, this.tabs});

  final MainTabController? tabs;

  void _close() => NavigationService.instance.pop();

  void _navigateTo(WaveDestination destination) {
    HapticManager.light();
    _close();
    final tab = _tabOf(destination);
    if (tab != null) {
      tabs?.select(tab);
      return;
    }
    final route = _routeOf(destination);
    if (route != null) NavigationService.instance.push(route);
  }

  static int? _tabOf(WaveDestination destination) => switch (destination) {
    WaveDestination.home => MainTabController.homeTab,
    WaveDestination.nutrition => MainTabController.nutritionTab,
    WaveDestination.workout => MainTabController.workoutTab,
    WaveDestination.habits => MainTabController.habitsTab,
    WaveDestination.progress => MainTabController.progressTab,
    _ => null,
  };

  static String? _routeOf(WaveDestination destination) => switch (destination) {
    WaveDestination.todaysWorkout => AppRouter.todaysWorkout,
    WaveDestination.activeWorkout => AppRouter.activeWorkout,
    WaveDestination.dietPlan => AppRouter.dietPlan,
    WaveDestination.weeklyNutritionReport => AppRouter.weeklyNutritionReport,
    WaveDestination.habitCalendar => AppRouter.habitCalendar,
    WaveDestination.foodScan => AppRouter.foodScan,
    WaveDestination.muscleRecovery => AppRouter.muscleRecovery,
    WaveDestination.achievements => AppRouter.achievements,
    WaveDestination.profile => AppRouter.profile,
    WaveDestination.editPersonalInfo => AppRouter.editPersonalInfo,
    WaveDestination.editDailyTargets => AppRouter.editDailyTargets,
    WaveDestination.connectedApps => AppRouter.connectedApps,
    WaveDestination.notificationSettings => AppRouter.notificationSettings,
    WaveDestination.units => AppRouter.units,
    WaveDestination.privacyData => AppRouter.privacyData,
    WaveDestination.waveMemory => AppRouter.waveMemory,
    WaveDestination.premium => AppRouter.premium,
    WaveDestination.none ||
    WaveDestination.home ||
    WaveDestination.nutrition ||
    WaveDestination.workout ||
    WaveDestination.habits ||
    WaveDestination.progress => null,
  };

  void _handlePlanAction(WaveChatViewModel viewModel, WavePlanItem item) {
    HapticManager.light();
    switch (item.action) {
      case WavePlanAction.startWorkout:
        _close();
        NavigationService.instance.push(AppRouter.todaysWorkout);
      case WavePlanAction.resumeWorkout:
        _openActiveWorkout();
      case WavePlanAction.logMeal:
        viewModel.sendQuickAction(WaveQuickAction.logMeal);
      case WavePlanAction.logWater:
        viewModel.logWater();
    }
  }

  Future<void> _openHistory(
    BuildContext context,
    WaveChatViewModel viewModel,
  ) async {
    HapticManager.light();
    final day = await WaveHistorySheet.show(
      context,
      days: viewModel.days,
      selectedDay: viewModel.selectedDay,
    );
    if (day != null) viewModel.selectDay(day);
  }

  Future<void> _listen(
    BuildContext context,
    WaveChatViewModel viewModel,
  ) async {
    primaryFocus?.unfocus();
    final text = await showWaveVoiceSheet(context);
    if (text != null) await viewModel.submitVoice(text);
  }

  void _openActiveWorkout() {
    HapticManager.medium();
    _close();
    NavigationService.instance.push(AppRouter.activeWorkout);
  }

  void _openMemory() {
    HapticManager.light();
    _close();
    NavigationService.instance.push(AppRouter.waveMemory);
  }

  void _openNutrition() {
    HapticManager.light();
    _close();
    NavigationService.instance.push(AppRouter.dietPlan);
  }

  Future<void> _upgrade() async {
    HapticManager.medium();
    await NavigationService.instance.push(AppRouter.premiumUpgrade);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.viewPaddingOf(context).top;
    final animation =
        ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;

    return Padding(
      padding: EdgeInsets.only(top: topPadding + AppSizes.s48),
      child: _WaveDismissibleSheet(
        onDismiss: _close,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: AppShapes.decoration(
              color: context.colors.backgroundPrimary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl4),
              ),
              side: BorderSide(
                color: context.colors.borderSubtle,
                width: AppSizes.s1,
              ),
            ),
            child: ChangeNotifierProvider(
              create: (_) => WaveChatViewModel(
                WaveChatService(),
                WaveContextService(),
                WaveTranscriptService(),
                onNavigate: _navigateTo,
                onUpgrade: _upgrade,
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      _WaveStaggerIn(
                        animation: animation,
                        interval: AppMotion.waveSheetHeaderIn,
                        child: _WaveSheetDragArea(
                          child: Selector<WaveChatViewModel, (String, bool)>(
                            selector: (_, viewModel) => (
                              viewModel.statusLabel,
                              viewModel.isReady || !viewModel.isViewingToday,
                            ),
                            builder: (context, status, child) => WaveChatHeader(
                              title: WaveChatViewModel.title,
                              status: status.$1,
                              isLive: status.$2,
                              onClose: _close,
                              onHistory: () => _openHistory(
                                context,
                                context.read<WaveChatViewModel>(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _WaveStaggerIn(
                          animation: animation,
                          interval: AppMotion.waveSheetBodyIn,
                          child: _WaveTranscriptPane(
                            onPlanAction: _handlePlanAction,
                            onOpenNutrition: _openNutrition,
                            onOpenWorkout: _openActiveWorkout,
                            onOpenMemory: _openMemory,
                          ),
                        ),
                      ),
                      _WaveStaggerIn(
                        animation: animation,
                        interval: AppMotion.waveSheetDockIn,
                        child: _WaveDock(onListen: _listen),
                      ),
                    ],
                  ),
                  const Positioned.fill(child: WaveSheetGlow()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveDismissibleSheet extends StatefulWidget {
  const _WaveDismissibleSheet({required this.onDismiss, required this.child});

  final VoidCallback onDismiss;
  final Widget child;

  @override
  State<_WaveDismissibleSheet> createState() => _WaveDismissibleSheetState();
}

class _WaveDismissibleSheetState extends State<_WaveDismissibleSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drag = AnimationController(
    vsync: this,
    duration: AppMotion.waveSheetSnapBack,
  );

  bool _dismissing = false;

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }

  void dragUpdate(DragUpdateDetails details) {
    final height = context.size?.height;
    if (_dismissing || height == null || height == 0) return;
    _drag.value += (details.primaryDelta ?? 0) / height;
  }

  void dragEnd(DragEndDetails details) {
    if (_dismissing) return;
    final velocity = details.primaryVelocity ?? 0;
    final shouldDismiss =
        velocity > AppMotion.waveSheetDismissVelocity ||
        (velocity >= 0 && _drag.value > AppMotion.waveSheetDismissFraction);
    if (shouldDismiss) {
      _dismissing = true;
      HapticManager.light();
      widget.onDismiss();
      return;
    }
    _drag.animateBack(0, curve: AppMotion.waveSheetSnapBackCurve);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _drag,
      builder: (context, child) => FractionalTranslation(
        translation: Offset(0, _drag.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _WaveSheetDragArea extends StatelessWidget {
  const _WaveSheetDragArea({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sheet = context.findAncestorStateOfType<_WaveDismissibleSheetState>();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: sheet?.dragUpdate,
      onVerticalDragEnd: sheet?.dragEnd,
      child: child,
    );
  }
}

class _WaveStaggerIn extends StatelessWidget {
  const _WaveStaggerIn({
    required this.animation,
    required this.interval,
    required this.child,
  });

  final Animation<double> animation;
  final Interval interval;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: interval);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, AppMotion.waveSheetContentRise),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _WaveTranscriptPane extends StatefulWidget {
  const _WaveTranscriptPane({
    required this.onPlanAction,
    required this.onOpenNutrition,
    required this.onOpenWorkout,
    required this.onOpenMemory,
  });

  final void Function(WaveChatViewModel, WavePlanItem) onPlanAction;
  final VoidCallback onOpenNutrition;
  final VoidCallback onOpenWorkout;
  final VoidCallback onOpenMemory;

  @override
  State<_WaveTranscriptPane> createState() => _WaveTranscriptPaneState();
}

class _WaveTranscriptPaneState extends State<_WaveTranscriptPane> {
  double _bannerHeight = 0;

  void _onBannerHeight(double height) {
    if (!mounted || height == _bannerHeight) return;
    setState(() => _bannerHeight = height);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AppPopRevealScope(
            child: Consumer<WaveChatViewModel>(
              builder: (context, viewModel, child) => AnimatedOpacity(
                opacity: viewModel.isLoaded ? 1 : 0,
                duration: AppMotion.expandSoft,
                curve: AppMotion.expandCurve,
                child: viewModel.isLoaded
                    ? _WaveTranscriptList(
                        viewModel: viewModel,
                        bannerHeight: _bannerHeight,
                        onPlanAction: (item) =>
                            widget.onPlanAction(viewModel, item),
                        onOpenNutrition: widget.onOpenNutrition,
                        onOpenWorkout: widget.onOpenWorkout,
                        onOpenMemory: widget.onOpenMemory,
                        onUpgrade: viewModel.upgrade,
                      )
                    : const SizedBox.expand(),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: AppSizes.s24,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: context.gradients.topFade),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Consumer<WaveChatViewModel>(
            builder: (context, viewModel, child) => viewModel.isQuotaLow
                ? WaveSizeReporter(
                    onHeight: _onBannerHeight,
                    child: WaveBottomFade(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                        child: WaveQuotaBanner(
                          message: viewModel.quotaMessage,
                          upsell: WaveChatViewModel.quotaUpsell,
                          actionLabel: WaveChatViewModel.upgradeLabel,
                          onUpgrade: viewModel.upgrade,
                        ),
                      ),
                    ),
                  )
                : WaveQuickActionBar(
                    visible: viewModel.showQuickActions,
                    actions: viewModel.quickActions,
                    onSelected: (action) {
                      HapticManager.light();
                      viewModel.sendQuickAction(action);
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _WaveDock extends StatelessWidget {
  const _WaveDock({required this.onListen});

  static const String backToTodayLabel = 'Back to Today';

  final Future<void> Function(BuildContext, WaveChatViewModel) onListen;

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.viewPaddingOf(context).bottom +
        AppSpacing.md;

    return Consumer<WaveChatViewModel>(
      builder: (context, viewModel, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: bottom,
            ),
            child: viewModel.isViewingToday
                ? WaveComposer(
                    controller: viewModel.composer,
                    hintText: WaveChatViewModel.composerHint,
                    canSend: viewModel.canSend,
                    onSubmit: () {
                      HapticManager.light();
                      viewModel.submitComposer();
                    },
                    onVoiceInput: viewModel.canUseVoice
                        ? () => onListen(context, viewModel)
                        : null,
                    meter: viewModel.showQuota
                        ? WaveQuotaMeter(
                            remaining: viewModel.quotaRemaining,
                            limit: viewModel.quotaLimit,
                            isLow: viewModel.isQuotaLow,
                            onTap: viewModel.upgrade,
                          )
                        : null,
                  )
                : PillButton(
                    variant: PillButtonVariant.neutral,
                    label: backToTodayLabel,
                    height: AppSizes.s48,
                    labelColor: context.colors.primary,
                    onPressed: () {
                      HapticManager.light();
                      viewModel.goToToday();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _WaveTranscriptList extends StatelessWidget {
  const _WaveTranscriptList({
    required this.viewModel,
    required this.bannerHeight,
    required this.onPlanAction,
    required this.onOpenNutrition,
    required this.onOpenWorkout,
    required this.onOpenMemory,
    required this.onUpgrade,
  });

  static const String _thinkingKey = 'wave_thinking';

  final WaveChatViewModel viewModel;
  final double bannerHeight;
  final ValueChanged<WavePlanItem> onPlanAction;
  final VoidCallback onOpenNutrition;
  final VoidCallback onOpenWorkout;
  final VoidCallback onOpenMemory;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final messages = viewModel.messages.reversed.toList();
    final offset = viewModel.isBusy ? 1 : 0;
    final itemCount = messages.length + offset;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        end: viewModel.showQuickActions
            ? AppSpacing.xl3 + AppSizes.s40 + AppSpacing.lg
            : viewModel.isQuotaLow
            ? AppSpacing.xl3 + bannerHeight
            : AppSpacing.xl3,
      ),
      duration: viewModel.showQuickActions
          ? AppMotion.waveSuggestionsShow
          : AppMotion.waveSuggestionsHide,
      curve: AppMotion.waveSuggestionsSize,
      builder: (context, bottomInset, child) => ListView.builder(
        controller: viewModel.scrollController,
        reverse: true,
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl3,
          bottom: bottomInset,
        ),
        itemCount: itemCount,
        findChildIndexCallback: (key) {
          if (key is! ValueKey<String>) return null;
          if (key.value == _thinkingKey) return viewModel.isBusy ? 0 : null;
          final index = messages.indexWhere(
            (message) => message.id == key.value,
          );
          return index < 0 ? null : index + offset;
        },
        itemBuilder: (context, index) {
          final spacing = EdgeInsets.only(
            top: index == itemCount - 1 ? 0 : AppSpacing.xl3,
          );

          if (viewModel.isBusy && index == 0) {
            return Padding(
              key: const ValueKey(_thinkingKey),
              padding: spacing,
              child: WaveMessageEntrance(
                animate: true,
                alignment: Alignment.bottomLeft,
                child: WaveThinkingIndicator(steps: viewModel.thinkingSteps),
              ),
            );
          }

          final message = messages[index - offset];
          return Padding(
            key: ValueKey(message.id),
            padding: spacing,
            child: WaveMessageEntrance(
              animate: viewModel.shouldEnter(message.id),
              onStarted: () => viewModel.markEntered(message.id),
              alignment: message is WaveUserMessage
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              child: WaveMessageItem(
                message: message,
                viewModel: viewModel,
                onPlanAction: onPlanAction,
                onOpenNutrition: onOpenNutrition,
                onOpenWorkout: onOpenWorkout,
                onOpenMemory: onOpenMemory,
                onUpgrade: onUpgrade,
              ),
            ),
          );
        },
      ),
    );
  }
}
