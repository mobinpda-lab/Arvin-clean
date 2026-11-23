/// Canonical REV10 Center domain entity.
///
/// Centers are persisted in the existing G1 SQLite database. Project links
/// are represented by the normalized center_projects relation, not embedded
/// in this entity.
class Center {
  const Center({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  Center copyWith({
    String? name,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return Center(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class CenterDeleteBlocked implements Exception {
  const CenterDeleteBlocked({
    required this.centerId,
    required this.projectCount,
    required this.taskCount,
  });

  final String centerId;
  final int projectCount;
  final int taskCount;

  @override
  String toString() =>
      'CenterDeleteBlocked: $centerId has $projectCount Project links and '
      '$taskCount direct Task assignments';
}
