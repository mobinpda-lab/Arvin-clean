class ArvinCenter {
  const ArvinCenter({required this.id, required this.name, this.isArchived = false, required this.createdAt});
  final String id;
  final String name;
  final bool isArchived;
  final DateTime createdAt;
  ArvinCenter copyWith({String? name, bool? isArchived}) => ArvinCenter(
    id: id, name: name ?? this.name, isArchived: isArchived ?? this.isArchived, createdAt: createdAt,
  );
}
class CenterDeleteBlocked implements Exception {
  const CenterDeleteBlocked(this.centerId, this.projectCount);
  final String centerId;
  final int projectCount;
}
