import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class VisibleConsumer<T extends Listenable> extends StatefulWidget {
  const VisibleConsumer({super.key, required this.builder, this.child});

  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  @override
  State<VisibleConsumer<T>> createState() => _VisibleConsumerState<T>();
}

class _VisibleConsumerState<T extends Listenable>
    extends State<VisibleConsumer<T>> {
  T? _listenable;
  bool _isVisible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isVisible = TickerMode.valuesOf(context).enabled;
    final listenable = Provider.of<T>(context, listen: false);
    if (identical(listenable, _listenable)) return;
    _listenable?.removeListener(_onChanged);
    _listenable = listenable..addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted || !_isVisible) return;
    setState(() {});
  }

  @override
  void dispose() {
    _listenable?.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _listenable as T, widget.child);
}
