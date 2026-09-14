import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progressive_blur/progressive_blur.dart';

class InnerPageScaffold extends StatelessWidget {
  const InnerPageScaffold({
    super.key,
    required this.title,
    required this.onBack,
    required this.children,
  });

  final String title;
  final VoidCallback onBack;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundPrimary,
      body: AppBackground(
        mode: AppBackgroundMode.flow,
        isInner: true,
        safeAreaTop: false,
        scrollable: false,
        child: Stack(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ProgressiveBlurWidget(
                sigma: 14,
                linearGradientBlur: LinearGradientBlur(
                  values: [0, 1],
                  stops: [.9, 1],
                  start: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                child: ListView(
                  padding: EdgeInsetsGeometry.only(
                    top: MediaQuery.viewPaddingOf(context).top + kToolbarHeight,
                    bottom:
                        MediaQuery.viewPaddingOf(context).bottom +
                        AppSpacing.xl3,
                    left: context.sizes.screenHorizontalPadding,
                    right: context.sizes.screenHorizontalPadding,
                  ),
                  children: [...children],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.viewPaddingOf(context).top,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  CupertinoButton(
                    onPressed: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Colors.
                      ),
                      child: Icon(Icons.arrow_back_ios)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
