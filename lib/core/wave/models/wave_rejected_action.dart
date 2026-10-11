import 'package:floww/core/wave/models/wave_action.dart';

enum WaveRejectReason { notFound, notAvailable, premium }

class WaveRejectedAction {
  const WaveRejectedAction({
    required this.kind,
    required this.target,
    required this.reason,
  });

  static List<WaveRejectedAction> listOf(Object? value) {
    if (value is! List) return const [];
    final rejected = <WaveRejectedAction>[];
    for (final item in value) {
      if (item is! Map) continue;
      final kind = WaveActionKind.values.asNameMap()[item['action']];
      final reason = WaveRejectReason.values.asNameMap()[item['reason']];
      if (kind == null || reason == null) continue;
      final target = item['target'];
      rejected.add(
        WaveRejectedAction(
          kind: kind,
          target: target is String ? target.trim() : '',
          reason: reason,
        ),
      );
    }
    return rejected;
  }

  final WaveActionKind kind;
  final String target;
  final WaveRejectReason reason;
}
