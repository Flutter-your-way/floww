import 'package:firebase_core/firebase_core.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/utils/effects/liquid_glass_shader.dart';
import 'package:floww/config/utils/effects/orb_shader.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/core/auth/services/auth_service.dart';
import 'package:floww/core/auth/view_models/auth_view_model.dart';
import 'package:floww/core/flow_mode/providers/flow_mode_controller.dart';
import 'package:floww/core/flow_mode/views/flow_mode_transition_host.dart';
import 'package:floww/core/health/providers/health_provider.dart';
import 'package:floww/core/health/services/health_service.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/premium/services/premium_service.dart';
import 'package:floww/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme/app_theme.dart';
import 'config/theme/theme_controller.dart';
import 'navigation/app_router.dart';
import 'navigation/services/navigation_service.dart';
import 'navigation/router_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LiquidGlassShader.preload();
  await OrbShader.preload();
  final prefs = await SharedPreferences.getInstance();
  final saved = AppThemeMode.values.firstWhere(
    (e) => e.name == (prefs.getString('app_theme_mode') ?? 'flow'),
    orElse: () => AppThemeMode.flow,
  );
  runApp(MainApp(initialMode: saved));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.initialMode});

  final AppThemeMode initialMode;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModeController(initialMode)),
        ChangeNotifierProxyProvider<ThemeModeController, FlowModeController>(
          create: (context) =>
              FlowModeController(context.read<ThemeModeController>()),
          update: (_, _, controller) => controller!,
        ),
        ChangeNotifierProvider(create: (_) => AuthViewModel(AuthService())),
        ChangeNotifierProvider(
          create: (_) => HealthProvider(HealthService())..restore(),
        ),
        ChangeNotifierProvider(
          create: (_) => PremiumAccessProvider(PremiumService())..start(),
        ),
      ],
      child: Consumer<ThemeModeController>(
        builder: (context, controller, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildTheme(controller.mode),
          themeAnimationDuration: AppMotion.modeShift,
          themeAnimationCurve: AppMotion.modeRelease,
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: AppRouter.splash,
          onGenerateRoute: AppRouterConfig.generateRoute,
          builder: (context, child) =>
              FlowModeTransitionHost(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
