import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/flow_mode/providers/flow_mode_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FlowModeDebugTrigger extends StatelessWidget {
  const FlowModeDebugTrigger({super.key, required this.child});

  final Widget child;

  static const List<AppThemeMode> _cycle = [
    AppThemeMode.restore,
    AppThemeMode.steady,
    AppThemeMode.flow,
  ];

  void _cycleMode(BuildContext context) {
    final controller = context.read<FlowModeController>();
    final next = _cycle[(_cycle.indexOf(controller.mode) + 1) % _cycle.length];
    HapticManager.selection();
    controller.debugForceTransition(next);
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onLongPress: () => _cycleMode(context),
      child: child,
    );
  }
}
