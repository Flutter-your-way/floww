import 'package:flutter/material.dart';

import 'package:floww/config/widgets/animations/tab_content_switcher.dart';

class IndexedContentSwitcher extends StatefulWidget {
  const IndexedContentSwitcher({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<IndexedContentSwitcher> createState() => _IndexedContentSwitcherState();
}

class _IndexedContentSwitcherState extends State<IndexedContentSwitcher> {
  bool _reverse = false;

  @override
  void didUpdateWidget(IndexedContentSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _reverse = widget.index < oldWidget.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabContentSwitcher(reverse: _reverse, child: widget.child);
  }
}
