import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';

class LazyTabStack extends StatefulWidget {
  const LazyTabStack({super.key, required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<LazyTabStack> createState() => _LazyTabStackState();
}

class _LazyTabStackState extends State<LazyTabStack> {
  late final Set<int> _visited = {widget.index};

  @override
  void didUpdateWidget(covariant LazyTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _visited.add(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          if (_visited.contains(i))
            _TabSlot(
              key: ValueKey(i),
              isActive: i == widget.index,
              child: widget.children[i],
            )
          else
            const SizedBox.shrink(),
      ],
    );
  }
}

class _TabSlot extends StatefulWidget {
  const _TabSlot({super.key, required this.isActive, required this.child});

  final bool isActive;
  final Widget child;

  @override
  State<_TabSlot> createState() => _TabSlotState();
}

class _TabSlotState extends State<_TabSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: AppMotion.tabReveal,
    value: 1,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _reveal,
    curve: AppMotion.tabRevealCurve,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: AppMotion.tabSwitchScale,
    end: 1,
  ).animate(_opacity);

  @override
  void didUpdateWidget(covariant _TabSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;
    if (widget.isActive) {
      _reveal.forward(from: 0);
    } else {
      _reveal.value = 0;
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;

    return Offstage(
      offstage: !isActive,
      child: TickerMode(
        enabled: isActive,
        child: HeroMode(
          enabled: isActive,
          child: ExcludeFocus(
            excluding: !isActive,
            child: FadeTransition(
              opacity: _opacity,
              child: ScaleTransition(scale: _scale, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
