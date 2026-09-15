import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/widgets/effects/bottom_action_scrim.dart';
import 'package:floww/config/widgets/effects/top_progressive_blur.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:flutter/material.dart';

class InnerPageScaffold extends StatefulWidget {
  const InnerPageScaffold({
    super.key,
    required this.title,
    required this.onBack,
    required this.children,
    this.onMore,
    this.footer,
  });

  final String title;
  final VoidCallback onBack;
  final List<Widget> children;
  final VoidCallback? onMore;
  final Widget? footer;

  @override
  State<InnerPageScaffold> createState() => _InnerPageScaffoldState();
}

class _InnerPageScaffoldState extends State<InnerPageScaffold> {
  static const _dividerFadeDuration = Duration(milliseconds: 180);

  final ScrollController _controller = ScrollController();
  final ValueNotifier<bool> _isScrolled = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    _isScrolled.value = _controller.offset > AppSpacing.md;
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _isScrolled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.sizes.screenHorizontalPadding;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final footer = widget.footer;
    final footerExtent = footer == null
        ? AppSpacing.xl3
        : AppSizes.s72 + AppSpacing.xl3;

    return Scaffold(
      backgroundColor: context.colors.backgroundPrimary,
      body: AppBackground(
        mode: AppBackgroundMode.flow,
        isInner: true,
        safeAreaTop: false,
        scrollable: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: TopProgressiveBlur(
                child: ListView(
                  controller: _controller,
                  padding: EdgeInsets.only(
                    top: viewPadding.top + kToolbarHeight + AppSpacing.md,
                    bottom: viewPadding.bottom + footerExtent,
                    left: horizontalPadding,
                    right: horizontalPadding,
                  ),
                  children: [...widget.children],
                ),
              ),
            ),
            Positioned(
              top:
                  TopProgressiveBlur.blurEdgeOf(context) +
                  context.sizes.topDividerOffset,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: _isScrolled,
                builder: (context, isScrolled, child) => AnimatedOpacity(
                  duration: _dividerFadeDuration,
                  opacity: isScrolled ? 1 : 0,
                  child: child,
                ),
                child: Divider(
                  height: AppSizes.s1,
                  thickness: AppSizes.s1,
                  color: context.colors.borderSubtle,
                ),
              ),
            ),
            Positioned(
              top: viewPadding.top,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: CustomHeader(
                  title: widget.title,
                  onBackPressed: widget.onBack,
                  onMorePressed: widget.onMore,
                ),
              ),
            ),
            if (footer != null) ...[
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomActionScrim(
                  height:
                      viewPadding.bottom +
                      AppSizes.s72 +
                      context.sizes.bottomScrimExtra,
                ),
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: viewPadding.bottom + AppSpacing.xl,
                child: footer,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
