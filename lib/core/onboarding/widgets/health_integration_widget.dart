import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:smooth_corner/smooth_corner.dart';

class HealthIntegrationWidget extends StatelessWidget {
  const HealthIntegrationWidget({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    required this.onConnect,
    this.statusLabel,
  });

  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onConnect;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizes.s120,
          height: AppSizes.s120,
          decoration: AppShapes.decoration(
            borderRadius: BorderRadius.circular(AppRadius.xl4),
            color: colors.primary,
          ),
          child: SmoothClipRRect(
            smoothness: AppShapes.smoothness,
            borderRadius: BorderRadius.circular(AppRadius.xl4),
            child: Image.asset(AppImages.appIcon, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        Icon(Icons.link, color: colors.textPrimary, size: AppSizes.s28),
        SizedBox(height: AppSpacing.xl),
        GestureDetector(
          onTap: isConnected || isConnecting ? null : onConnect,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl2,
              vertical: AppSpacing.xl,
            ),
            decoration: AppShapes.decoration(
              color: colors.backgroundSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(
                color: isConnected ? colors.primary : colors.backgroundSecondary,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: AppSizes.s48,
                  height: AppSizes.s48,
                  decoration: AppShapes.decoration(
                    color: colors.textPrimary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppImages.appleHealthIcon,
                      width: AppSizes.s24,
                      height: AppSizes.s24,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Apple Health',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      if (statusLabel != null) ...[
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          statusLabel!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                _ConnectPill(
                  isConnected: isConnected,
                  isConnecting: isConnecting,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConnectPill extends StatelessWidget {
  const _ConnectPill({required this.isConnected, required this.isConnecting});

  final bool isConnected;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: isConnected ? colors.tintStrong : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: isConnected ? colors.primary : colors.borderMedium,
        ),
      ),
      child: isConnecting
          ? SizedBox(
              width: AppSizes.s16,
              height: AppSizes.s16,
              child: CircularProgressIndicator(
                strokeWidth: AppSizes.s2,
                color: colors.primary,
              ),
            )
          : Text(
              isConnected ? 'Connected' : 'Connect',
              style: context.textTheme.bodyMedium?.copyWith(
                color: isConnected ? colors.primary : colors.textPrimary,
              ),
            ),
    );
  }
}
