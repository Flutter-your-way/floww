import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/effects/bottom_action_scrim.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/core/profile/view_models/profile_photo_crop_view_model.dart';
import 'package:floww/core/profile/widgets/profile_photo_crop_area.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class ProfilePhotoCropView extends StatelessWidget {
  ProfilePhotoCropView({super.key});

  final GlobalKey _boundaryKey = GlobalKey();

  Future<void> _confirm(ProfilePhotoCropViewModel viewModel) async {
    HapticManager.light();
    final bytes = await viewModel.crop(_boundaryKey);
    if (bytes == null) {
      HapticManager.error();
      return;
    }
    NavigationService.instance.pop(bytes);
  }

  void _reset(ProfilePhotoCropViewModel viewModel) {
    HapticManager.selection();
    viewModel.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfilePhotoCropViewModel>(
      builder: (context, viewModel, child) {
        final colors = context.colors;
        final viewPadding = MediaQuery.viewPaddingOf(context);
        final horizontalPadding = context.sizes.screenHorizontalPadding;
        final errorMessage = viewModel.errorMessage;

        return Scaffold(
          backgroundColor: colors.backgroundPrimary,
          body: AppBackground(
            mode: AppBackgroundMode.active(context),
            isInner: true,
            safeAreaTop: false,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      SizedBox(
                        height:
                            viewPadding.top + kToolbarHeight + AppSpacing.xl3,
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final stageSize = viewModel.stageSizeFor(
                              constraints,
                            );
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => viewModel.prepare(stageSize),
                            );

                            return Center(
                              child: ProfilePhotoCropArea(
                                boundaryKey: _boundaryKey,
                                bytes: viewModel.source,
                                transformation: viewModel.transformation,
                                stageSize: stageSize,
                                cropRect: viewModel.cropRect,
                                isReady: viewModel.isReady,
                                minScale: ProfilePhotoCropViewModel.minScale,
                                maxScale: ProfilePhotoCropViewModel.maxScale,
                                onInteractionEnd: viewModel.onInteractionEnd,
                                onCornerDrag: viewModel.resizeCrop,
                                onCropDrag: viewModel.moveCrop,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl2),
                      Text(
                        viewModel.hint,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmallRegularTight.copyWith(
                          color: colors.textSubtle,
                        ),
                      ),
                      if (errorMessage != null) ...[
                        SizedBox(height: AppSpacing.lg),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmallMediumTight.copyWith(
                            color: colors.destructive,
                          ),
                        ),
                      ],
                      SizedBox(
                        height:
                            viewPadding.bottom + AppSizes.s72 + AppSpacing.xl3,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: viewPadding.top,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: CustomHeader(
                      title: viewModel.title,
                      onBackPressed: () => NavigationService.instance.pop(),
                      moreIcon: Icons.refresh_rounded,
                      onMorePressed: viewModel.canReset
                          ? () => _reset(viewModel)
                          : null,
                    ),
                  ),
                ),
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
                  child: PillButton(
                    variant: PillButtonVariant.primary,
                    label: viewModel.confirmLabel,
                    isLoading: viewModel.isCropping,
                    onPressed: viewModel.isReady
                        ? () => _confirm(viewModel)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
