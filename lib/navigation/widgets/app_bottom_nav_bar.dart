import 'dart:async';

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
    if (index == selectedIndex) {
      HapticManager.soft();
      return;
    }
    HapticManager.rigid();
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
          child: Row(
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
        ),
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

class _NavTabButtonState extends State<_NavTabButton>
    with TickerProviderStateMixin {
  late final AnimationController _selection = AnimationController(
    vsync: this,
    duration: AppGlass.indicatorPopIn,
    reverseDuration: AppGlass.indicatorPopOut,
    value: widget.isSelected ? 1 : 0,
  );

  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: AppGlass.indicatorBurst,
  );

  late final Animation<double> _pop = CurvedAnimation(
    parent: _selection,
    curve: AppGlass.indicatorPopCurve,
    reverseCurve: AppGlass.indicatorPopOutCurve,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _selection,
    curve: AppGlass.indicatorPopFade,
    reverseCurve: Curves.easeIn,
  );

  bool _isPressed = false;
  Timer? _settleHaptic;

  @override
  void didUpdateWidget(_NavTabButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected == widget.isSelected) return;
    if (widget.isSelected) {
      _selection.forward();
      _burst.forward(from: 0);
      _scheduleSettleHaptic();
    } else {
      _selection.reverse();
      _settleHaptic?.cancel();
    }
  }

  void _scheduleSettleHaptic() {
    _settleHaptic?.cancel();
    _settleHaptic = Timer(AppGlass.indicatorPopSettle, () {
      HapticManager.soft();
    });
  }

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  void dispose() {
    _settleHaptic?.cancel();
    _selection.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            duration: AppMotion.press,
            curve: Curves.easeOut,
            child: SizedBox(
              width: AppGlass.indicatorSize,
              height: AppGlass.indicatorSize,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  _NavIndicatorBurst(animation: _burst),
                  _NavIndicatorPop(pop: _pop, fade: _fade),
                  _NavTabIcon(item: widget.item, pop: _pop),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIndicatorPop extends StatelessWidget {
  const _NavIndicatorPop({required this.pop, required this.fade});

  final Animation<double> pop;
  final Animation<double> fade;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pop,
      builder: (context, child) {
        final t = pop.value;
        if (t <= 0) return const SizedBox.shrink();

        final scale =
            AppGlass.indicatorPopScale + (1 - AppGlass.indicatorPopScale) * t;
        final jelly = (t - 1) * AppGlass.indicatorPopSquash;

        return Opacity(
          opacity: fade.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * AppGlass.indicatorPopRise),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(
                scale * (1 + jelly),
                scale * (1 - jelly),
                1,
              ),
              child: child,
            ),
          ),
        );
      },
      child: const _IndicatorGlass(),
    );
  }
}

class _NavIndicatorBurst extends StatelessWidget {
  const _NavIndicatorBurst({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = AppGlass.indicatorBurstCurve.transform(animation.value);
        if (t <= 0 || t >= 1) return const SizedBox.shrink();

        return Opacity(
          opacity: AppGlass.indicatorBurstOpacity * (1 - t),
          child: Transform.scale(
            scale: 1 + AppGlass.indicatorBurstScale * t,
            child: child,
          ),
        );
      },
      child: SizedBox.square(
        dimension: AppGlass.indicatorSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.colors.primary,
              width: AppGlass.indicatorBurstWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicatorGlass extends StatelessWidget {
  const _IndicatorGlass();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppGlass.indicatorSize,
      child: DecoratedBox(
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
      ),
    );
  }
}

class _NavTabIcon extends StatelessWidget {
  const _NavTabIcon({required this.item, required this.pop});

  final NavTabItem item;
  final Animation<double> pop;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pop,
      builder: (context, child) {
        final t = pop.value.clamp(0.0, 1.0);
        final color = Color.lerp(
          context.colors.textMuted,
          context.colors.textPrimary,
          t,
        );

        return Transform.translate(
          offset: Offset(0, -AppGlass.iconLiftSelected * t),
          child: Transform.scale(
            scale: 1 + (AppGlass.iconPopScale - 1) * t,
            child: SvgPicture.asset(
              item.iconAsset,
              width: AppSizes.s20,
              height: AppSizes.s20,
              colorFilter: ColorFilter.mode(
                color ?? context.colors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
        );
      },
    );
  }
}
