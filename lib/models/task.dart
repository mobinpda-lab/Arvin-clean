class Task {
  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.followUpDate,
    this.tags = const [],
    this.archived = false,
    this.trashed = false,
    this.completed = false,
  });

  final String id;
  String title;
  String description;
  DateTime? followUpDate;
  List<String> tags;
  bool archived;
  bool trashed;
  bool completed;

  factory Task.fromDescription({
    required String id,
    required String description,
    String? title,
  }) {
    final first = description
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trim())
        .firstWhere((e) => e.isNotEmpty, orElse: () => '');
    return Task(
      id: id,
      title: title?.trim().isNotEmpty == true ? title!.trim() : first,
      description: description,
    );
  }
}
