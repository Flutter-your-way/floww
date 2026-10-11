import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class WaveSizeReporter extends SingleChildRenderObjectWidget {
  const WaveSizeReporter({
    super.key,
    required this.onHeight,
    required super.child,
  });

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderWaveSizeReporter(onHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderWaveSizeReporter renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class RenderWaveSizeReporter extends RenderProxyBox {
  RenderWaveSizeReporter(this.onHeight);

  ValueChanged<double> onHeight;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (height == _reported) return;
    _reported = height;
    WidgetsBinding.instance.addPostFrameCallback((_) => onHeight(height));
  }
}
