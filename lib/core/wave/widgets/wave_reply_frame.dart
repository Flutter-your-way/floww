import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/images/wave_avatar_badge.dart';

class WaveReplyFrame extends StatelessWidget {
  const WaveReplyFrame({
    super.key,
    required this.child,
    this.footer,
    this.fillWidth = false,
  });

  static const double maxWidthFactor = 0.88;
  static const double footerHeight = AppSizes.s28;
  static const double avatarSize = AppSizes.s24;

  final Widget child;
  final Widget? footer;
  final bool fillWidth;

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        if (footer != null) SizedBox(height: footerHeight, child: footer),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: footer == null ? 0 : footerHeight),
          child: const WaveAvatarBadge(size: avatarSize, contained: true),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: FractionallySizedBox(
            widthFactor: maxWidthFactor,
            alignment: Alignment.centerLeft,
            child: fillWidth
                ? content
                : Align(
                    alignment: Alignment.centerLeft,
                    child: IntrinsicWidth(child: content),
                  ),
          ),
        ),
      ],
    );
  }
}
