import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/achievements/services/achievements_service.dart';
import 'package:floww/core/flow_mode/providers/flow_mode_controller.dart';
import 'package:floww/core/flow_mode/widgets/flow_mode_ambient_layer.dart';
import 'package:floww/core/health/providers/health_provider.dart';
import 'package:floww/core/health/services/health_log_service.dart';
import 'package:floww/core/home/providers/home_provider.dart';
import 'package:floww/core/home/services/home_service.dart';
import 'package:floww/core/home/services/home_snapshot_builder.dart';
import 'package:floww/core/profile/services/profile_service.dart';
import 'package:floww/core/wave/views/wave_chat_sheet.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/core/workout/view_models/workout_view_model.dart';
import 'package:floww/core/workout/view_models/exercise_library_view_model.dart';
import 'package:floww/core/workout/views/workout_view.dart';
import 'package:floww/core/home/views/home_view.dart';
import 'package:floww/core/nutrition/services/diet_plan_service.dart';
import 'package:floww/core/nutrition/services/nutrition_goal_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/nutrition_view_model.dart';
import 'package:floww/core/nutrition/views/nutrition_view.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/habits/services/habit_source_sync.dart';
import 'package:floww/core/habits/view_models/habits_view_model.dart';
import 'package:floww/core/habits/views/habits_view.dart';
import 'package:floww/core/progress/services/progress_service.dart';
import 'package:floww/core/progress/view_models/progress_view_model.dart';
import 'package:floww/core/progress/views/progress_view.dart';
import 'package:floww/navigation/view_models/main_tab_controller.dart';
import 'package:floww/navigation/widgets/app_bottom_nav_bar.dart';
import 'package:floww/navigation/widgets/lazy_tab_stack.dart';
import 'package:floww/navigation/widgets/wave_orb_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  final MainTabController _controller = MainTabController();

  static const _tabs = [
    NavTabItem(iconAsset: AppImages.tab_1, semanticLabel: 'Home'),
    NavTabItem(iconAsset: AppImages.tab_2, semanticLabel: 'Nutrition'),
    NavTabItem(iconAsset: AppImages.tab_3, semanticLabel: 'Activity'),
    NavTabItem(iconAsset: AppImages.tab_4, semanticLabel: 'Habits'),
    NavTabItem(iconAsset: AppImages.tab_5, semanticLabel: 'Progress'),
  ];

  static final _screens = [
    HomeView(),
    ChangeNotifierProvider(
      create: (context) => NutritionViewModel(
        NutritionLogService(),
        DietPlanService(NutritionLogService()),
        NutritionGoalService(),
      ),
      child: NutritionView(),
    ),
    _workoutTab(),
    ChangeNotifierProvider(
      create: (context) => HabitsViewModel(HabitService()),
      child: HabitsView(),
    ),
    ChangeNotifierProvider(
      create: (context) => ProgressViewModel(ProgressService()),
      child: ProgressView(),
    ),
  ];

  static HomeProvider _createHomeProvider(
    FlowModeController flowModeController,
  ) {
    final nutritionLogService = NutritionLogService();
    final sessionService = WorkoutSessionService();
    final progressService = ProgressService(
      nutritionLogService: nutritionLogService,
    );
    final achievementsService = AchievementsService(
      progressService: progressService,
      sessionService: sessionService,
      nutritionLogService: nutritionLogService,
    );

    return HomeProvider(
      HomeService(
        ProfileService(),
        HabitService(),
        nutritionLogService,
        WorkoutPlanService(WorkoutCatalogService()),
        sessionService,
        HealthLogService(),
        progressService,
      ),
      HomeSnapshotBuilder(),
      achievementsService,
      flowModeController,
    );
  }

  static Widget _workoutTab() {
    final catalogService = WorkoutCatalogService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => WorkoutViewModel(
            WorkoutSessionService(),
            WorkoutPlanService(catalogService),
            WorkoutProgramService(),
            catalogService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ExerciseLibraryViewModel(catalogService),
        ),
      ],
      child: WorkoutView(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HealthProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (context) =>
              _createHomeProvider(context.read<FlowModeController>()),
        ),
        Provider(
          lazy: false,
          create: (context) =>
              HabitSourceSync(context.read<HealthProvider>())..start(),
          dispose: (context, HabitSourceSync sync) => sync.dispose(),
        ),
      ],
      child: ChangeNotifierProvider.value(
        value: _controller,
        child: Consumer<MainTabController>(
          builder: (context, controller, child) =>
              _buildScaffold(context, controller),
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, MainTabController controller) {
    return Scaffold(
      backgroundColor: context.colors.backgroundPrimary,
      body: Stack(
        children: [
          Positioned.fill(
            child: LazyTabStack(index: controller.index, children: _screens),
          ),
          const Positioned.fill(child: FlowModeAmbientLayer()),
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: MediaQuery.viewPaddingOf(context).bottom,
            child: Row(
              children: [
                Expanded(
                  child: AppBottomNavBar(
                    items: _tabs,
                    selectedIndex: controller.index,
                    onTabSelected: controller.select,
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                WaveOrbButton(
                  onTap: () {
                    HapticManager.light();
                    showWaveChatSheet(context);
                  },
                ),
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
