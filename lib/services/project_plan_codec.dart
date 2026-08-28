import '../models/goal_project.dart';

/// Lossless JSON-shape codec for Arvin's canonical [ProjectPlan].
///
/// This is intentionally storage-agnostic. It defines one portable Project
/// representation without introducing a second Task store, Task projectId, or
/// persistence key. A later persistence/backup lane can reuse this exact shape.
class ProjectPlanCodec {
  const ProjectPlanCodec();

  static const int defaultColorValue = 0xFF4A4CAB;

  Map<String, dynamic> encode(ProjectPlan project) {
    return <String, dynamic>{
      'id': project.id,
      'title': project.title,
      'colorValue': project.colorValue,
      'itemIds': List<String>.of(project.itemIds),
    };
  }

  ProjectPlan decode(Object? raw) {
    if (raw is! Map) {
      throw const FormatException('Project must be a JSON object');
    }

    final map = Map<String, dynamic>.from(raw);
    final id = map['id'];
    final title = map['title'];
    if (id is! String || id.trim().isEmpty) {
      throw const FormatException('Project id must be a non-empty string');
    }
    if (title is! String) {
      throw const FormatException('Project title must be a string');
    }

    final rawColor = map['colorValue'];
    final colorValue = rawColor is int ? rawColor : defaultColorValue;

    final rawItemIds = map['itemIds'];
    final itemIds = rawItemIds == null
        ? const <String>[]
        : _decodeItemIds(rawItemIds);

    return ProjectPlan(
      id: id,
      title: title,
      colorValue: colorValue,
      itemIds: itemIds,
    );
  }

  List<Map<String, dynamic>> encodeList(Iterable<ProjectPlan> projects) {
    return projects.map(encode).toList(growable: false);
  }

  List<ProjectPlan> decodeList(Object? raw) {
    if (raw is! List) {
      throw const FormatException('Projects must be a JSON list');
    }
    return List<ProjectPlan>.unmodifiable(raw.map(decode));
  }

  List<String> _decodeItemIds(Object raw) {
    if (raw is! List) {
      throw const FormatException('Project itemIds must be a JSON list');
    }
    final result = <String>[];
    for (final value in raw) {
      if (value is! String || value.isEmpty) {
        throw const FormatException(
          'Project itemIds must contain only non-empty strings',
        );
      }
      result.add(value);
    }
    return List<String>.unmodifiable(result);
  }
}
