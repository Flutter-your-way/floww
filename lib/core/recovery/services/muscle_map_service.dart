import 'package:flutter/services.dart';

import 'package:floww/core/recovery/models/muscle_body_side.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/services/muscle_map_data.dart';

class MuscleMapTemplate {
  const MuscleMapTemplate({
    required this.header,
    required this.shapes,
    required this.groupOfShape,
  });

  final String header;
  final List<String> shapes;
  final Map<int, MuscleGroup> groupOfShape;

  String paint(Map<MuscleGroup, Color> palette) {
    final buffer = StringBuffer(header);
    for (var i = 0; i < shapes.length; i++) {
      final shape = shapes[i];
      final color = palette[groupOfShape[i]];
      if (color != null) {
        buffer.write(
          shape.replaceFirst(
            MuscleMapService.fillPattern,
            'fill="${MuscleMapService.toHex(color)}"',
          ),
        );
        continue;
      }
      buffer.write(
        shape.replaceFirst(
          'fill="${MuscleMapService.highlightFill}"',
          'fill="${MuscleMapService.baseFill}"',
        ),
      );
    }
    buffer.write('</svg>');
    return buffer.toString();
  }
}

class MuscleMapService {
  static const String highlightFill = '#BAFF1F';
  static const String baseFill = '#BDBDBD';
  static final RegExp fillPattern = RegExp('fill="#[0-9A-Fa-f]{6}"');

  static final RegExp _headerPattern = RegExp('<svg[^>]*>');
  static final RegExp _shapePattern = RegExp('<path[^>]*>');

  final Map<MuscleBodySide, MuscleMapTemplate> _templates = {};

  MuscleMapTemplate? templateOf(MuscleBodySide side) => _templates[side];

  Future<void> load() async {
    for (final side in MuscleBodySide.values) {
      if (_templates.containsKey(side)) continue;
      final source = await rootBundle.loadString(MuscleMapData.assets[side]!);
      _templates[side] = _parse(side, source);
    }
  }

  static MuscleMapTemplate _parse(MuscleBodySide side, String source) {
    final shapes = _shapePattern
        .allMatches(source)
        .map((match) => match.group(0)!)
        .toList();
    final groupOfShape = <int, MuscleGroup>{};
    MuscleMapData.shapes[side]!.forEach((group, indexes) {
      for (final index in indexes) {
        groupOfShape[index] = group;
      }
    });
    return MuscleMapTemplate(
      header: _headerPattern.firstMatch(source)!.group(0)!,
      shapes: shapes,
      groupOfShape: groupOfShape,
    );
  }

  static String toHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
}
