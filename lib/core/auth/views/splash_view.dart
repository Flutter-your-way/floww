import 'package:floww/config/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/auth/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:smooth_corner/smooth_corner.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final user = await context.read<AuthViewModel>().restoreSession();
    if (!mounted) return;

    if (user == null) {
      NavigationService.instance.pushReplacement(AppRouter.meetWaves);
    } else {
      NavigationService.instance.pushAndRemoveUntil(
        AppRouter.routeAfterAuth(user),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundSurface,
      body: Center(
        child: SmoothClipRRect(
          smoothness: AppShapes.smoothness,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Image.asset(
            'assets/icons/app_icon.png',
            width: 120,
            height: 120,
          ),
        ),
      ),
    );
  }
}
