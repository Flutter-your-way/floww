import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_glass.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/effects/inner_glow.dart';
import 'package:floww/config/widgets/effects/liquid_glass.dart';
import 'package:floww/navigation/views/main_tab_view.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<NavTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  void _handleTap(int index) {
    if (index != selectedIndex) HapticManager.selection();
    onTabSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.s64,
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(AppRadius.full),
        shadows: [
          BoxShadow(
            color: context.colors.backgroundPrimary.withValues(
              alpha: AppGlass.shadowOpacity,
            ),
            blurRadius: AppGlass.shadowBlur,
            offset: const Offset(0, AppGlass.shadowOffset),
          ),
        ],
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: _LiquidNavIndicator(
                  selectedIndex: selectedIndex,
                  itemCount: items.length,
                ),
              ),
              Row(
                children: List.generate(
                  items.length,
                  (index) => Expanded(
                    child: _NavTabButton(
                      item: items[index],
                      isSelected: index == selectedIndex,
                      onTap: () => _handleTap(index),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidNavIndicator extends StatefulWidget {
  const _LiquidNavIndicator({
    required this.selectedIndex,
    required this.itemCount,
  });

  final int selectedIndex;
  final int itemCount;

  @override
  State<_LiquidNavIndicator> createState() => _LiquidNavIndicatorState();
}

class _LiquidNavIndicatorState extends State<_LiquidNavIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppGlass.indicatorTravel,
  );
  late final Animation<double> _travel = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  late double _from = widget.selectedIndex.toDouble();
  late double _to = widget.selectedIndex.toDouble();

  @override
  void didUpdateWidget(_LiquidNavIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex == widget.selectedIndex) return;
    _from = _position;
    _to = widget.selectedIndex.toDouble();
    _controller.forward(from: 0);
  }

  double get _position => _from + (_to - _from) * _travel.value;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / widget.itemCount;
        final top = (constraints.maxHeight - AppGlass.indicatorSize) / 2;

        return AnimatedBuilder(
          animation: _travel,
          builder: (context, child) {
            final distance = (_to - _from).abs();
            final pull =
                math.sin(_travel.value * math.pi) *
                distance *
                AppGlass.indicatorStretch;
            final left =
                _position * segmentWidth +
                (segmentWidth - AppGlass.indicatorSize) / 2;

            return Stack(
              children: [
                Positioned(
                  left: left,
                  top: top,
                  width: AppGlass.indicatorSize,
                  height: AppGlass.indicatorSize,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(
                      1 + pull,
                      1 - pull * AppGlass.indicatorSquash,
                      1,
                    ),
                    child: child,
                  ),
                ),
              ],
            );
          },
          child: const _IndicatorGlass(),
        );
      },
    );
  }
}

class _IndicatorGlass extends StatelessWidget {
  const _IndicatorGlass();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: context.gradients.glassIndicator,
        border: Border.all(
          color: context.colors.textPrimary.withValues(
            alpha: AppGlass.indicatorRimOpacity,
          ),
          width: AppSizes.s1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(
              alpha: AppGlass.indicatorGlowOpacity,
            ),
            blurRadius: AppGlass.indicatorGlowBlur,
          ),
        ],
      ),
      child: InnerGlow(
        color: context.colors.textPrimary.withValues(
          alpha: AppGlass.innerGlowOpacity,
        ),
        radius: AppGlass.indicatorSize / 2,
      ),
    );
  }
}

class _NavTabButton extends StatefulWidget {
  const _NavTabButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NavTabItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavTabButton> createState() => _NavTabButtonState();
}

class _NavTabButtonState extends State<_NavTabButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final targetColor = widget.isSelected
        ? context.colors.textPrimary
        : context.colors.textMuted;

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.item.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: Center(
          child: AnimatedScale(
            scale: _isPressed ? AppMotion.pressScale : 1,
            duration: AppGlass.iconFade,
            curve: Curves.easeOutBack,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: targetColor),
              duration: AppGlass.iconFade,
              curve: Curves.easeInOut,
              builder: (context, animatedColor, child) => SvgPicture.asset(
                widget.item.iconAsset,
                width: AppSizes.s20,
                height: AppSizes.s20,
                colorFilter: ColorFilter.mode(
                  animatedColor ?? targetColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
