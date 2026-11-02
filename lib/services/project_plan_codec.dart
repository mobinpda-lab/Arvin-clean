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
      'isArchived': project.isArchived,
      if (project.centerId != null) 'centerId': project.centerId,
      if (project.templateId != null) 'templateId': project.templateId,
      if (project.templateNameSnapshot != null) 'templateNameSnapshot': project.templateNameSnapshot,
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

    final rawArchived = map['isArchived'];
    if (rawArchived != null && rawArchived is! bool) {
      throw const FormatException('Project isArchived must be a boolean');
    }
    final isArchived = rawArchived is bool ? rawArchived : false;

    final rawCenterId = map['centerId'];
    if (rawCenterId != null && (rawCenterId is! String || rawCenterId.trim().isEmpty)) {
      throw const FormatException('Project centerId must be a non-empty string when present');
    }
    final rawTemplateId = map['templateId'];
    final rawTemplateName = map['templateNameSnapshot'];
    if (rawTemplateId != null && (rawTemplateId is! String || rawTemplateId.trim().isEmpty)) throw const FormatException('Project templateId must be non-empty when present');
    if (rawTemplateName != null && rawTemplateName is! String) throw const FormatException('Project templateNameSnapshot must be a string');
    final rawItemIds = map['itemIds'];
    final itemIds = rawItemIds == null
        ? const <String>[]
        : _decodeItemIds(rawItemIds);

    return ProjectPlan(
      id: id,
      title: title,
      colorValue: colorValue,
      isArchived: isArchived,
      centerId: rawCenterId as String?,
      templateId: rawTemplateId as String?,
      templateNameSnapshot: rawTemplateName as String?,
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
