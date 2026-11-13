enum ExerciseVideoKind {
  gym('gym'),
  yoga('yoga');

  const ExerciseVideoKind(this.value);

  final String value;
}

class ExerciseVideo {
  const ExerciseVideo({
    required this.videoUrl,
    required this.isPortrait,
    required this.expiresAt,
    this.thumbnailUrl,
  });

  static ExerciseVideo? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final videoUrl = json['videoUrl'];
    final expiresAt = DateTime.tryParse(json['expiresAt'] as String? ?? '');
    if (videoUrl is! String || videoUrl.isEmpty || expiresAt == null) {
      return null;
    }
    return ExerciseVideo(
      videoUrl: videoUrl,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isPortrait: json['isPortrait'] as bool? ?? true,
      expiresAt: expiresAt,
    );
  }

  final String videoUrl;
  final String? thumbnailUrl;
  final bool isPortrait;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'videoUrl': videoUrl,
    'thumbnailUrl': thumbnailUrl,
    'isPortrait': isPortrait,
    'expiresAt': expiresAt.toIso8601String(),
  };
}
