import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/headers/custom_header.dart';
import 'package:floww/core/nutrition/view_models/food_scan_view_model.dart';
import 'package:floww/core/nutrition/widgets/food_scan_camera_preview.dart';
import 'package:floww/core/nutrition/widgets/food_scan_controls.dart';
import 'package:floww/core/nutrition/widgets/food_scan_overlay.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class FoodScanView extends StatelessWidget {
  const FoodScanView({super.key});

  Future<void> _capture(
    BuildContext context,
    FoodScanViewModel viewModel,
  ) async {
    HapticManager.medium();
    final food = await viewModel.captureAndScan();
    if (food != null && context.mounted) NavigationService.instance.pop(food);
  }

  Future<void> _pickPhoto(
    BuildContext context,
    FoodScanViewModel viewModel,
  ) async {
    HapticManager.light();
    final food = await viewModel.pickPhotoAndScan();
    if (food != null && context.mounted) NavigationService.instance.pop(food);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final horizontalPadding = context.sizes.screenHorizontalPadding;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.colors.backgroundPrimary,
        body: Consumer<FoodScanViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                FoodScanCameraPreview(
                  controller: viewModel.cameraController,
                  photo: viewModel.scannedPhoto,
                ),
                FoodScanOverlay(isScanning: viewModel.isScanning),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: bottomInset + AppSpacing.lg,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: context.gradients.cameraScrim,
                    ),
                  ),
                ),
                Positioned(
                  top: topInset,
                  left: horizontalPadding,
                  right: horizontalPadding,
                  child: CustomHeader(
                    title: 'AI Food Scan',
                    onBackPressed: () => NavigationService.instance.pop(),
                  ),
                ),
                Positioned(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: bottomInset + AppSizes.s40,
                  child: FoodScanControls(
                    visible: !viewModel.isScanning,
                    showShutter: viewModel.showShutter,
                    message: viewModel.errorMessage,
                    onCapture: viewModel.canCapture
                        ? () => _capture(context, viewModel)
                        : null,
                    onPickPhoto: viewModel.canPickPhoto
                        ? () => _pickPhoto(context, viewModel)
                        : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
