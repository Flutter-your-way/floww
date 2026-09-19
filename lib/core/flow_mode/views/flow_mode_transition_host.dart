import 'package:floww/core/flow_mode/providers/flow_mode_controller.dart';
import 'package:floww/core/flow_mode/widgets/flow_mode_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FlowModeTransitionHost extends StatefulWidget {
  const FlowModeTransitionHost({super.key, required this.child});

  final Widget child;

  @override
  State<FlowModeTransitionHost> createState() => _FlowModeTransitionHostState();
}

class _FlowModeTransitionHostState extends State<FlowModeTransitionHost> {
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onStateChange: _onLifecycleChange);
  }

  void _onLifecycleChange(AppLifecycleState state) {
    if (!mounted) return;
    context.read<FlowModeController>().setAppActive(
      state == AppLifecycleState.resumed,
    );
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FlowModeController>();
    final change = controller.activeTransition;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (change != null)
          FlowModeTransition(
            key: ValueKey(change.id),
            mode: change.mode,
            previousMode: change.previousMode,
            onThemeApply: controller.applyTransitionTheme,
            onCompleted: controller.completeTransition,
          ),
      ],
    );
  }
}
