enum WaveSummarySection {
  ongoing,
  agreed,
  open;

  String get label => switch (this) {
    WaveSummarySection.ongoing => 'Ongoing',
    WaveSummarySection.agreed => 'Agreed',
    WaveSummarySection.open => 'Follow Up',
  };
}

class WaveSummaryItem {
  const WaveSummaryItem({required this.section, required this.text});

  static const String _sectionField = 'section';
  static const String _textField = 'text';
  static const String _bulletPrefix = '- ';

  factory WaveSummaryItem.fromJson(Map<String, dynamic> json) =>
      WaveSummaryItem(
        section:
            WaveSummarySection.values.asNameMap()[json[_sectionField]] ??
            WaveSummarySection.ongoing,
        text: (json[_textField] as String? ?? '').trim(),
      );

  static List<WaveSummaryItem> listOf(Map<String, dynamic>? data) {
    final items = data?['items'];
    if (items is List) {
      return [
        for (final item in items)
          if (item is Map)
            if (WaveSummaryItem.fromJson(Map<String, dynamic>.from(item))
                case final parsed when parsed.text.isNotEmpty)
              parsed,
      ];
    }
    final legacy = data?['summary'] as String? ?? '';
    return [
      for (final line in legacy.split('\n'))
        if (line.trim().replaceFirst(_bulletPrefix, '').trim() case final text
            when text.isNotEmpty)
          WaveSummaryItem(section: WaveSummarySection.ongoing, text: text),
    ];
  }

  final WaveSummarySection section;
  final String text;

  Map<String, dynamic> toJson() => {
    _sectionField: section.name,
    _textField: text,
  };
}
