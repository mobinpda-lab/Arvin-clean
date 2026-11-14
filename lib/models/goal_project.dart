class ProjectPlan {
  ProjectPlan({
    required this.id,
    required this.title,
    this.colorValue = 0xFF087F8C,
    this.isArchived = false,
    String? centerId,
    Iterable<String>? centerIds,
    Iterable<String>? categoryIds,
    this.templateId,
    this.templateNameSnapshot,
    Iterable<String> itemIds = const [],
    Map<String, dynamic> legacyFields = const {},
  })  : centerIds = _stableIds(centerIds ?? (centerId == null ? const [] : [centerId])),
        centerRelationshipsSpecified = centerIds != null || centerId != null,
        categoryIds = _stableIds(categoryIds ?? const []),
        categoryRelationshipsSpecified = categoryIds != null,
        itemIds = List.unmodifiable(itemIds),
        legacyFields = Map.unmodifiable(Map<String, dynamic>.from(legacyFields));

  static List<String> _stableIds(Iterable<String> values) {
    final result = values.where((value) => value.trim().isNotEmpty).toSet().toList()..sort();
    return List<String>.unmodifiable(result);
  }

  final String id;
  final String title;
  final int colorValue;
  final bool isArchived;

  /// Canonical in-memory projection of the SQL center_projects relation.
  final List<String> centerIds;
  final bool centerRelationshipsSpecified;

  /// Canonical in-memory projection of the SQL project_categories relation.
  final List<String> categoryIds;
  final bool categoryRelationshipsSpecified;

  /// Backward-compatible single-parent view. It is not an independent source
  /// of truth: it returns the sole Center only when exactly one is linked.
  String? get centerId => centerIds.length == 1 ? centerIds.single : null;

  final String? templateId;
  final String? templateNameSnapshot;
  final List<String> itemIds;

  /// Unknown fields from historical JSON/backup envelopes are carried through
  /// codec round-trips but are never used as relational storage.
  final Map<String, dynamic> legacyFields;

  bool get hasItems => itemIds.isNotEmpty;
  bool get canDelete => itemIds.isEmpty;

  ProjectPlan copyWith({
    String? title,
    int? colorValue,
    bool? isArchived,
    Iterable<String>? itemIds,
    String? centerId,
    bool clearCenterId = false,
    Iterable<String>? centerIds,
    bool replaceCenterIds = false,
    Iterable<String>? categoryIds,
    bool replaceCategoryIds = false,
    String? templateId,
    bool clearTemplateId = false,
    String? templateNameSnapshot,
    bool clearTemplateNameSnapshot = false,
    Map<String, dynamic>? legacyFields,
  }) {
    final nextCenters = replaceCenterIds
        ? (centerIds ?? const <String>[])
        : clearCenterId
            ? const <String>[]
            : centerId != null
                ? [centerId]
                : centerIds ?? this.centerIds;
    return ProjectPlan(
      id: id,
      title: title ?? this.title,
      colorValue: colorValue ?? this.colorValue,
      isArchived: isArchived ?? this.isArchived,
      centerIds: nextCenters,
      categoryIds: replaceCategoryIds ? categoryIds ?? const [] : categoryIds ?? this.categoryIds,

      templateId: clearTemplateId ? null : templateId ?? this.templateId,
      templateNameSnapshot: clearTemplateNameSnapshot
          ? null
          : templateNameSnapshot ?? this.templateNameSnapshot,
      itemIds: itemIds ?? this.itemIds,
      legacyFields: legacyFields ?? this.legacyFields,
    );
  }

  ProjectPlan replaceCenters(Iterable<String> ids) =>
      copyWith(centerIds: ids, replaceCenterIds: true);

  ProjectPlan removeCenter(String id) =>
      copyWith(centerIds: centerIds.where((value) => value != id), replaceCenterIds: true);

  ProjectPlan replaceCategories(Iterable<String> ids) =>
      copyWith(categoryIds: ids, replaceCategoryIds: true);

  ProjectPlan removeCategory(String id) =>
      copyWith(categoryIds: categoryIds.where((value) => value != id), replaceCategoryIds: true);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectPlan &&
          other.id == id &&
          other.title == title &&
          other.colorValue == colorValue &&
          other.isArchived == isArchived &&
          _same(centerIds, other.centerIds) &&
          _same(categoryIds, other.categoryIds) &&
          other.centerRelationshipsSpecified == centerRelationshipsSpecified &&
          other.categoryRelationshipsSpecified == categoryRelationshipsSpecified &&
          other.templateId == templateId &&
          other.templateNameSnapshot == templateNameSnapshot &&
          _same(itemIds, other.itemIds) &&
          _mapSame(legacyFields, other.legacyFields);

  @override
  int get hashCode => Object.hash(
        id, title, colorValue, isArchived,
        Object.hashAll(centerIds), Object.hashAll(categoryIds),
        centerRelationshipsSpecified, categoryRelationshipsSpecified,
        templateId, templateNameSnapshot, Object.hashAll(itemIds),
        Object.hashAll(legacyFields.entries.map((entry) => Object.hash(entry.key, entry.value))),
      );

  static bool _same(List<String> a, List<String> b) =>
      a.length == b.length && List.generate(a.length, (i) => a[i] == b[i]).every((v) => v);

  static bool _mapSame(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) return false;
    }
    return true;
  }
}

class GoalPlan {
  GoalPlan({
    required this.id,
    required this.title,
    Iterable<ProjectPlan> projects = const [],
  }) : projects = List.unmodifiable(projects);

  final String id;
  final String title;
  final List<ProjectPlan> projects;
}

class ProjectDeleteBlocked implements Exception {
  const ProjectDeleteBlocked(this.projectId);
  final String projectId;
  @override
  String toString() => 'ProjectDeleteBlocked: project $projectId still contains canonical items';
}

class ProjectLifecycleService {
  const ProjectLifecycleService();

  List<ProjectPlan> add(Iterable<ProjectPlan> projects, ProjectPlan project) {
    final current = List<ProjectPlan>.of(projects);
    if (current.any((item) => item.id == project.id)) {
      throw ArgumentError.value(project.id, 'project.id', 'Duplicate Project id');
    }
    return List.unmodifiable([...current, project]);
  }

  List<ProjectPlan> edit(
    Iterable<ProjectPlan> projects, {
    required String projectId,
    String? title,
    int? colorValue,
    String? centerId,
    bool clearCenterId = false,
    Iterable<String>? centerIds,
    bool replaceCenterIds = false,
    Iterable<String>? categoryIds,
    bool replaceCategoryIds = false,
  }) {
    var found = false;
    final next = projects.map((project) {
      if (project.id != projectId) return project;
      found = true;
      return project.copyWith(
        title: title, colorValue: colorValue, centerId: centerId,
        clearCenterId: clearCenterId, centerIds: centerIds,
        replaceCenterIds: replaceCenterIds, categoryIds: categoryIds,
        replaceCategoryIds: replaceCategoryIds,
      );
    }).toList(growable: false);
    if (!found) throw ArgumentError.value(projectId, 'projectId', 'Unknown Project');
    return List.unmodifiable(next);
  }

  List<ProjectPlan> setArchived(
    Iterable<ProjectPlan> projects, {
    required String projectId,
    required bool isArchived,
  }) {
    var found = false;
    final next = projects.map((project) {
      if (project.id != projectId) return project;
      found = true;
      return project.copyWith(isArchived: isArchived);
    }).toList(growable: false);
    if (!found) throw ArgumentError.value(projectId, 'projectId', 'Unknown Project');
    return List.unmodifiable(next);
  }

  List<ProjectPlan> delete(Iterable<ProjectPlan> projects, {required String projectId}) {
    final current = List<ProjectPlan>.of(projects);
    final index = current.indexWhere((project) => project.id == projectId);
    if (index < 0) throw ArgumentError.value(projectId, 'projectId', 'Unknown Project');
    if (!current[index].canDelete) throw ProjectDeleteBlocked(projectId);
    current.removeAt(index);
    return List.unmodifiable(current);
  }

  List<ProjectPlan> assignTask(
    Iterable<ProjectPlan> projects, {
    required String taskId,
    required String? projectId,
  }) {
    final current = List<ProjectPlan>.of(projects);
    if (projectId != null && !current.any((project) => project.id == projectId)) {
      throw ArgumentError.value(projectId, 'projectId', 'Unknown Project');
    }
    return List.unmodifiable(current.map((project) {
      final nextIds = project.itemIds.where((id) => id != taskId).toList();
      if (project.id == projectId) nextIds.add(taskId);
      return project.copyWith(itemIds: nextIds);
    }).toList(growable: false));
  }
}

class GoalProjectValidation {
  GoalProjectValidation({
    required Iterable<String> missingItemIds,
    required Iterable<String> duplicateItemIds,
    required Iterable<String> duplicateProjectIds,
  })  : missingItemIds = List.unmodifiable(missingItemIds),
        duplicateItemIds = List.unmodifiable(duplicateItemIds),
        duplicateProjectIds = List.unmodifiable(duplicateProjectIds);
  final List<String> missingItemIds;
  final List<String> duplicateItemIds;
  final List<String> duplicateProjectIds;
  bool get isValid => missingItemIds.isEmpty && duplicateItemIds.isEmpty && duplicateProjectIds.isEmpty;
}

class GoalProjectService {
  const GoalProjectService();
  GoalProjectValidation validate(GoalPlan goal, {required Iterable<String> canonicalItemIds}) {
    final knownItems = canonicalItemIds.toSet();
    final seenItems = <String>{};
    final duplicateItems = <String>{};
    final missingItems = <String>{};
    final seenProjects = <String>{};
    final duplicateProjects = <String>{};
    for (final project in goal.projects) {
      if (!seenProjects.add(project.id)) duplicateProjects.add(project.id);
      for (final itemId in project.itemIds) {
        if (!knownItems.contains(itemId)) missingItems.add(itemId);
        if (!seenItems.add(itemId)) duplicateItems.add(itemId);
      }
    }
    return GoalProjectValidation(
      missingItemIds: missingItems.toList()..sort(),
      duplicateItemIds: duplicateItems.toList()..sort(),
      duplicateProjectIds: duplicateProjects.toList()..sort(),
    );
  }
}
