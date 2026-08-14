import 'follow_up.dart';

class Task {
  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.followUpDate,
    this.followUps = const <FollowUp>[],
    this.tags = const [],
    this.archived = false,
    this.trashed = false,
    this.completed = false,
  });

  final String id;
  String title;
  String description;
  DateTime? followUpDate;
  List<FollowUp> followUps;
  List<String> tags;
  bool archived;
  bool trashed;
  bool completed;

  /// Returns the most recent follow-up, if any.
  FollowUp? get latestFollowUp {
    if (followUps.isEmpty) return null;
    return followUps.reduce(
      (a, b) => a.dateTime.isAfter(b.dateTime) ? a : b,
    );
  }

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
