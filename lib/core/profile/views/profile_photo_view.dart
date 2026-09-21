import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/core/profile/models/profile_photo_args.dart';
import 'package:floww/core/profile/widgets/profile_photo_zoom_area.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class ProfilePhotoView extends StatelessWidget {
  const ProfilePhotoView({super.key, required this.args});

  final ProfilePhotoArgs args;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final horizontalPadding = context.sizes.screenHorizontalPadding;

    return Scaffold(
      backgroundColor: context.colors.backgroundPrimary,
      body: AppBackground(
        mode: AppBackgroundMode.active(context),
        isInner: true,
        safeAreaTop: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: viewPadding.top + AppSpacing.xl5,
              ),
              child: ProfilePhotoZoomArea(
                imageUrl: args.imageUrl,
                imageBytes: args.imageBytes,
              ),
            ),
            Positioned(
              top: viewPadding.top,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: CustomHeader(
                  title: args.title,
                  onClosePressed: () => NavigationService.instance.pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
