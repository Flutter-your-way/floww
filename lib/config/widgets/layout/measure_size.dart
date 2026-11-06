import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MeasureSize extends SingleChildRenderObjectWidget {
  const MeasureSize({super.key, required this.onChange, super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderMeasureSize).onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _lastSize;

  @override
  void performLayout() {
    super.performLayout();
    final measured = size;
    if (measured == _lastSize) return;
    _lastSize = measured;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(measured));
  }
}
