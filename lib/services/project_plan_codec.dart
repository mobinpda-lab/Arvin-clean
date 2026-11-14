import '../models/goal_project.dart';

/// Single portable codec for the canonical Project model and backup boundary.
class ProjectPlanCodec {
  const ProjectPlanCodec();
  static const int defaultColorValue = 0xFF087F8C;

  static const Set<String> _known = {
    'id', 'title', 'colorValue', 'isArchived', 'centerId', 'centerIds',
    'categoryIds', 'templateId', 'templateNameSnapshot', 'itemIds',
  };

  Map<String, dynamic> encode(ProjectPlan project) {
    return <String, dynamic>{
      ...project.legacyFields,
      'id': project.id,
      'title': project.title,
      'colorValue': project.colorValue,
      'isArchived': project.isArchived,
      'centerIds': List<String>.of(project.centerIds),
      'categoryIds': List<String>.of(project.categoryIds),
      if (project.centerId != null) 'centerId': project.centerId,
      if (project.templateId != null) 'templateId': project.templateId,
      if (project.templateNameSnapshot != null)
        'templateNameSnapshot': project.templateNameSnapshot,
      'itemIds': List<String>.of(project.itemIds),
    };
  }

  ProjectPlan decode(Object? raw) {
    if (raw is! Map) throw const FormatException('Project must be a JSON object');
    final map = Map<String, dynamic>.from(raw);
    final id = map['id'];
    final title = map['title'];
    if (id is! String || id.trim().isEmpty) {
      throw const FormatException('Project id must be a non-empty string');
    }
    if (title is! String) throw const FormatException('Project title must be a string');

    final rawColor = map['colorValue'];
    if (rawColor != null && rawColor is! int) {
      throw const FormatException('Project colorValue must be an integer');
    }
    final rawArchived = map['isArchived'];
    if (rawArchived != null && rawArchived is! bool) {
      throw const FormatException('Project isArchived must be a boolean');
    }

    final legacyCenter = map['centerId'];
    if (legacyCenter != null &&
        (legacyCenter is! String || legacyCenter.trim().isEmpty)) {
      throw const FormatException('Project centerId must be a non-empty string when present');
    }
    final centers = map.containsKey('centerIds')
        ? (map['centerIds'] == null ? const <String>[] : _decodeIds(map['centerIds'], 'centerIds'))
        : legacyCenter == null ? null : <String>[legacyCenter as String];
    if (legacyCenter != null && centers.isNotEmpty && !centers.contains(legacyCenter)) {
      throw const FormatException('Project centerId conflicts with centerIds');
    }

    final categories = map.containsKey('categoryIds')
        ? (map['categoryIds'] == null ? const <String>[] : _decodeIds(map['categoryIds'], 'categoryIds'))
        : null;
    final rawTemplateId = map['templateId'];
    final rawTemplateName = map['templateNameSnapshot'];
    if (rawTemplateId != null &&
        (rawTemplateId is! String || rawTemplateId.trim().isEmpty)) {
      throw const FormatException('Project templateId must be non-empty when present');
    }
    if (rawTemplateName != null && rawTemplateName is! String) {
      throw const FormatException('Project templateNameSnapshot must be a string');
    }

    final unknown = <String, dynamic>{
      for (final entry in map.entries)
        if (!_known.contains(entry.key)) entry.key: entry.value,
    };
    return ProjectPlan(
      id: id,
      title: title,
      colorValue: rawColor as int? ?? defaultColorValue,
      isArchived: rawArchived as bool? ?? false,
      centerIds: centers,
      categoryIds: categories,
      templateId: rawTemplateId as String?,
      templateNameSnapshot: rawTemplateName as String?,
      itemIds: !map.containsKey('itemIds') ? null : map['itemIds'] == null ? const <String>[] : _decodeIds(map['itemIds'], 'itemIds'),
      legacyFields: unknown,
    );
  }

  List<String> _decodeIds(Object? raw, String field) {
    if (raw is! List) throw FormatException('Project $field must be a JSON list');
    final values = <String>[];
    for (final value in raw) {
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Project $field must contain only non-empty strings');
      }
      values.add(value);
    }
    return values;
  }

  List<Map<String, dynamic>> encodeList(Iterable<ProjectPlan> projects) =>
      projects.map(encode).toList(growable: false);

  List<ProjectPlan> decodeList(Object? raw) {
    if (raw is! List) throw const FormatException('Projects must be a JSON list');
    return List<ProjectPlan>.unmodifiable(raw.map(decode));
  }
}
