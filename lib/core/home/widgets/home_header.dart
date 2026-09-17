import 'package:flutter/material.dart';
import 'package:floww/config/widgets/headers/profile_title_header.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.streakCount,
    this.avatarUrl,
    this.onAvatarTap,
    this.onStreakTap,
  });

  final String greeting;
  final String userName;
  final int streakCount;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onStreakTap;

  @override
  Widget build(BuildContext context) {
    return ProfileTitleHeader(
      eyebrow: '$greeting,',
      title: userName,
      streakCount: streakCount,
      avatarUrl: avatarUrl,
      onAvatarTap: onAvatarTap,
      onStreakTap: onStreakTap,
    );
  }
}
