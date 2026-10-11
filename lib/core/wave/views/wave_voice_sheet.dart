import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/theme/sheet_theme.dart';
import 'package:floww/core/wave/services/wave_speech_service.dart';
import 'package:floww/core/wave/view_models/wave_voice_view_model.dart';
import 'package:floww/core/wave/widgets/wave_backdrop.dart';
import 'package:floww/core/wave/widgets/wave_sheet_glow.dart';
import 'package:floww/core/wave/widgets/wave_voice_orb.dart';

Future<String?> showWaveVoiceSheet(BuildContext context) {
  final forcedMode = SheetTheme.forcedModeOf(context);
  HapticManager.light();

  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: AppMotion.waveVoiceEnter,
    pageBuilder: (context, animation, secondaryAnimation) =>
        SheetTheme(forcedMode: forcedMode, child: const WaveVoiceSheet()),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.waveVoiceEnterCurve,
        reverseCurve: AppMotion.collapseCurve,
      );

      return SheetTheme(
        forcedMode: forcedMode,
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: FadeTransition(
                opacity: curved,
                child: const WaveBackdrop(),
              ),
            ),
            FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, AppMotion.waveVoiceEnterRise),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: AppMotion.waveVoiceEnterScale,
                    end: 1,
                  ).animate(curved),
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class WaveVoiceSheet extends StatefulWidget {
  const WaveVoiceSheet({super.key});

  @override
  State<WaveVoiceSheet> createState() => _WaveVoiceSheetState();
}

class _WaveVoiceSheetState extends State<WaveVoiceSheet> {
  late final WaveVoiceViewModel _viewModel = WaveVoiceViewModel(
    WaveSpeechService.instance,
    onFinished: _close,
  );

  bool _closed = false;

  void _close(String? text) {
    if (_closed || !mounted) return;
    _closed = true;
    if (text != null) HapticManager.medium();
    Navigator.of(context).pop(text);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return ChangeNotifierProvider<WaveVoiceViewModel>.value(
      value: _viewModel,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: viewPadding.bottom + AppSpacing.lg,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: AppShapes.decoration(
                color: context.colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppRadius.xl4),
                side: BorderSide(
                  color: context.colors.borderSubtle,
                  width: AppSizes.s1,
                ),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(child: WaveSheetGlow()),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xl,
                    ),
                    child: Consumer<WaveVoiceViewModel>(
                      builder: (context, viewModel, child) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _WaveVoiceHeader(
                            label: viewModel.statusLabel,
                            isLive: viewModel.isListening,
                            onClose: viewModel.cancel,
                          ),
                          SizedBox(height: AppSpacing.xl3),
                          RepaintBoundary(
                            child: WaveVoiceOrb(
                              level: viewModel.level,
                              isActive: viewModel.isListening,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xl),
                          RepaintBoundary(
                            child: _WaveLevelBars(
                              level: viewModel.isListening
                                  ? viewModel.level
                                  : 0,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xl),
                          _WaveVoiceTranscript(
                            text:
                                viewModel.failureMessage ??
                                (viewModel.hasTranscript
                                    ? viewModel.transcript
                                    : WaveVoiceViewModel.hint),
                            isPlaceholder:
                                viewModel.failureMessage != null ||
                                !viewModel.hasTranscript,
                          ),
                          SizedBox(height: AppSpacing.xl4),
                          _WaveVoiceActions(
                            isFailed: viewModel.state == WaveVoiceState.failed,
                            canFinish: viewModel.canFinish,
                            onCancel: viewModel.cancel,
                            onFinish: viewModel.finish,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveVoiceHeader extends StatelessWidget {
  const _WaveVoiceHeader({
    required this.label,
    required this.isLive,
    required this.onClose,
  });

  final String label;
  final bool isLive;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isLive ? colors.primary : colors.textSubtle;

    return Row(
      children: [
        const SizedBox.square(dimension: AppSizes.s32),
        Expanded(
          child: Center(
            child: AnimatedContainer(
              duration: AppMotion.expand,
              height: AppSizes.s32,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: AppShapes.decoration(
                color: isLive ? colors.tint : colors.backgroundElevated,
                borderRadius: BorderRadius.circular(AppRadius.full),
                side: BorderSide(
                  color: isLive ? colors.borderGlow : colors.borderSubtle,
                  width: AppSizes.s1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.expand,
                    width: AppSizes.s6,
                    height: AppSizes.s6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  AnimatedSwitcher(
                    duration: AppMotion.waveThinkingSwap,
                    child: Text(
                      label,
                      key: ValueKey(label),
                      style: context.textTheme.labelMedium?.copyWith(
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        CircularHeaderButton(
          icon: Icons.close_rounded,
          size: AppSizes.s32,
          iconSize: AppSizes.s16,
          iconColor: colors.textSubtle,
          backgroundColor: colors.backgroundElevated,
          onPressed: onClose,
        ),
      ],
    );
  }
}

class _WaveLevelBars extends StatelessWidget {
  const _WaveLevelBars({required this.level});

  static const List<double> _weights = [0.35, 0.6, 0.85, 1, 0.85, 0.6, 0.35];

  final double level;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.s28,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < _weights.length; index++) ...[
            if (index > 0) SizedBox(width: AppSpacing.xs),
            AnimatedContainer(
              duration: AppMotion.waveVoiceLevel,
              curve: Curves.easeOut,
              width: AppSizes.s4,
              height: AppSizes.s4 + (AppSizes.s24 * _weights[index] * level),
              decoration: AppShapes.decoration(
                color: level > 0
                    ? context.colors.primary
                    : context.colors.borderMedium,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WaveVoiceTranscript extends StatelessWidget {
  const _WaveVoiceTranscript({required this.text, required this.isPlaceholder});

  final String text;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppMotion.waveRevealGrow,
      curve: AppMotion.waveRevealGrowCurve,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: AppSizes.s120),
        child: SingleChildScrollView(
          reverse: true,
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: isPlaceholder
                  ? context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.textDim,
                    )
                  : context.textTheme.titleMedium?.copyWith(
                      color: context.colors.textPrimary,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveVoiceActions extends StatelessWidget {
  const _WaveVoiceActions({
    required this.isFailed,
    required this.canFinish,
    required this.onCancel,
    required this.onFinish,
  });

  static const String closeLabel = 'Close';

  final bool isFailed;
  final bool canFinish;
  final VoidCallback onCancel;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    if (isFailed) {
      return PillButton(
        variant: PillButtonVariant.neutral,
        label: closeLabel,
        height: AppSizes.s48,
        width: double.infinity,
        onPressed: onCancel,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _WaveVoiceRoundButton(icon: Icons.close_rounded, onTap: onCancel),
        SizedBox(width: AppSpacing.xl5),
        _WaveVoiceRoundButton(
          icon: Icons.arrow_upward_rounded,
          filled: true,
          onTap: canFinish ? onFinish : null,
        ),
      ],
    );
  }
}

class _WaveVoiceRoundButton extends StatelessWidget {
  const _WaveVoiceRoundButton({
    required this.icon,
    this.filled = false,
    this.onTap,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = filled && onTap != null;

    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.expand,
        curve: AppMotion.expandCurve,
        width: AppSizes.s56,
        height: AppSizes.s56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: active ? context.gradients.primary : null,
          color: active ? null : colors.backgroundElevated,
          border: Border.all(color: colors.borderSubtle, width: AppSizes.s1),
        ),
        child: Icon(
          icon,
          size: AppSizes.s24,
          color: active
              ? context.scheme.onPrimary
              : filled
              ? colors.textSubtle
              : colors.textPrimary,
        ),
      ),
    );
  }
}
