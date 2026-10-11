class WaveQuota {
  const WaveQuota({
    required this.used,
    required this.limit,
    required this.remaining,
    required this.isPremium,
  });

  static const int warningAt = 5;

  static WaveQuota? fromJson(Object? value) {
    if (value is! Map) return null;
    final limit = _count(value['limit']);
    if (limit == null) return null;
    final used = _count(value['used']) ?? 0;
    return WaveQuota(
      used: used,
      limit: limit,
      remaining: _count(value['remaining']) ?? (limit - used).clamp(0, limit),
      isPremium: value['premium'] == true,
    );
  }

  static int? _count(Object? value) => value is num ? value.toInt() : null;

  final int used;
  final int limit;
  final int remaining;
  final bool isPremium;

  bool get isExhausted => remaining <= 0;

  bool get isLow => !isPremium && remaining <= warningAt;

  WaveQuota get consumed => WaveQuota(
    used: (used + 1).clamp(0, limit),
    limit: limit,
    remaining: (remaining - 1).clamp(0, limit),
    isPremium: isPremium,
  );

  WaveQuota get exhausted =>
      WaveQuota(used: limit, limit: limit, remaining: 0, isPremium: isPremium);
}
