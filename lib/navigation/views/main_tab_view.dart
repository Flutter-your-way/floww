import 'dart:ui' as ui;

import 'package:animations/animations.dart';
import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/activity/views/activity_view.dart';
import 'package:floww/core/home/views/home_view.dart';
import 'package:floww/core/nutrition/services/diet_plan_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/nutrition_view_model.dart';
import 'package:floww/core/nutrition/views/nutrition_view.dart';
import 'package:floww/core/plans/views/plans_view.dart';
import 'package:floww/core/stats/views/stats_view.dart';
import 'package:floww/navigation/widgets/app_bottom_nav_bar.dart';
import 'package:floww/navigation/widgets/wave_orb_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  static const _tabTransitionDuration = Duration(milliseconds: 300);

  int _selectedIndex = 0;

  static const _tabs = [
    NavTabItem(iconAsset: AppImages.tab_1, semanticLabel: 'Home'),
    NavTabItem(iconAsset: AppImages.tab_2, semanticLabel: 'Nutrition'),
    NavTabItem(iconAsset: AppImages.tab_3, semanticLabel: 'Activity'),
    NavTabItem(iconAsset: AppImages.tab_4, semanticLabel: 'Plans'),
    NavTabItem(iconAsset: AppImages.tab_5, semanticLabel: 'Stats'),
  ];

  static final _screens = [
    HomeView(),
    ChangeNotifierProvider(
      create: (context) => NutritionViewModel(
        NutritionLogService(),
        DietPlanService(NutritionLogService()),
      ),
      child: NutritionView(),
    ),
    ActivityView(),
    PlansView(),
    StatsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundPrimary,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageTransitionSwitcher(
              duration: _tabTransitionDuration,
              transitionBuilder:
                  (child, primaryAnimation, secondaryAnimation) =>
                      FadeThroughTransition(
                        animation: primaryAnimation,
                        secondaryAnimation: secondaryAnimation,
                        fillColor: context.colors.backgroundPrimary,
                        child: child,
                      ),
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: _screens[_selectedIndex],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.viewPaddingOf(context).bottom + AppSizes.s64,
            child: const _BlurredFooter(),
          ),
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: MediaQuery.viewPaddingOf(context).bottom,
            child: Row(
              children: [
                Expanded(
                  child: AppBottomNavBar(
                    items: _tabs,
                    selectedIndex: _selectedIndex,
                    onTabSelected: (index) =>
                        setState(() => _selectedIndex = index),
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                WaveOrbButton(onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavTabItem {
  const NavTabItem({required this.iconAsset, required this.semanticLabel});

  final String iconAsset;
  final String semanticLabel;
}

class _BlurredFooter extends StatelessWidget {
  const _BlurredFooter();

  static const _bandFractions = [1.0, 0.8, 0.6, 0.4, 0.2];
  static const _bandSigma = 1.2;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final fraction in _bandFractions)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: FractionallySizedBox(
              heightFactor: fraction,
              alignment: Alignment.bottomCenter,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: _bandSigma,
                    sigmaY: _bandSigma,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.colors.backgroundPrimary.withValues(alpha: 0),
                  context.colors.backgroundPrimary.withValues(alpha: 0.28),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
