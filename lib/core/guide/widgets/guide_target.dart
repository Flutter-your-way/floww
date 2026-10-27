import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/core/guide/models/guide_step.dart';
import 'package:floww/core/guide/providers/guide_controller.dart';

class GuideTarget extends StatefulWidget {
  const GuideTarget({
    super.key,
    required this.id,
    required this.child,
    this.radius = AppRadius.xl,
    this.padding = AppSpacing.sm,
  });

  final GuideTargetId id;
  final Widget child;
  final double radius;
  final double padding;

  @override
  State<GuideTarget> createState() => _GuideTargetState();
}

class _GuideTargetState extends State<GuideTarget> {
  late final GuideController _guide;

  GuideTargetEntry get _entry => GuideTargetEntry(
    context: context,
    radius: widget.radius,
    padding: widget.padding,
  );

  @override
  void initState() {
    super.initState();
    _guide = context.read<GuideController>();
    _guide.registerTarget(widget.id, _entry);
  }

  @override
  void didUpdateWidget(GuideTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _guide.unregisterTarget(oldWidget.id, context);
    }
    _guide.registerTarget(widget.id, _entry);
  }

  @override
  void dispose() {
    _guide.unregisterTarget(widget.id, context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
