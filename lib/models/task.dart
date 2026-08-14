class FollowUp {
  final String id;
  final DateTime dateTime;
  final String note;
  final String? result;
  final DateTime? nextFollowUp;

  const FollowUp({
    required this.id,
    required this.dateTime,
    this.note = '',
    this.result,
    this.nextFollowUp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'note': note,
        'result': result,
        'nextFollowUp': nextFollowUp?.toIso8601String(),
      };

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      id: json['id'] as String? ?? '',
      dateTime: DateTime.parse(json['dateTime'] as String),
      note: json['note'] as String? ?? '',
      result: json['result'] as String?,
      nextFollowUp: json['nextFollowUp'] == null
          ? null
          : DateTime.parse(json['nextFollowUp'] as String),
    );
  }
}

/// Primary Arvin task model with backward-compatible follow-up history.
class ArvinTask {
  ArvinTask({
    required this.id,
    required this.title,
    this.description = '',
    this.followUpDate,
    this.tags = const [],
    this.archived = false,
    this.trashed = false,
    this.completed = false,
    this.followUps = const [],
  });

  final String id;
  String title;
  String description;

  /// Legacy field kept so existing backups/data remain readable.
  DateTime? followUpDate;

  List<String> tags;
  bool archived;
  bool trashed;
  bool completed;
  List<FollowUp> followUps;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'followUpDate': followUpDate?.toIso8601String(),
        'tags': tags,
        'archived': archived,
        'trashed': trashed,
        'completed': completed,
        'followUps': followUps.map((e) => e.toJson()).toList(),
      };

  factory ArvinTask.fromJson(Map<String, dynamic> json) {
    final loadedFollowUps = <FollowUp>[];
    final rawFollowUps = json['followUps'];

    if (rawFollowUps is List) {
      for (final item in rawFollowUps) {
        if (item is Map) {
          loadedFollowUps.add(
            FollowUp.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    // Migrate the legacy single follow-up date exactly once on load.
    if (loadedFollowUps.isEmpty && json['followUpDate'] is String) {
      final oldDate = DateTime.tryParse(json['followUpDate'] as String);
      if (oldDate != null) {
        loadedFollowUps.add(
          FollowUp(
            id: 'legacy-${oldDate.microsecondsSinceEpoch}',
            dateTime: oldDate,
            note: 'مهاجرت خودکار از تاریخ پیگیری قبلی',
          ),
        );
      }
    }

    return ArvinTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      followUpDate: json['followUpDate'] == null
          ? null
          : DateTime.tryParse(json['followUpDate'] as String),
      tags: (json['tags'] as List<dynamic>? ?? []).whereType<String>().toList(),
      archived: json['archived'] as bool? ?? false,
      trashed: json['trashed'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
      followUps: loadedFollowUps,
    );
  }

  /// Returns the most recent follow-up by timestamp, regardless of list order.
  FollowUp? get lastFollowUp {
    if (followUps.isEmpty) return null;
    return followUps.reduce(
      (current, candidate) =>
          candidate.dateTime.isAfter(current.dateTime) ? candidate : current,
    );
  }

  DateTime? get lastFollowUpDate => lastFollowUp?.dateTime;

  /// Adds a follow-up and keeps the legacy date field synchronized.
  void addFollowUp(FollowUp followUp) {
    followUps = List<FollowUp>.from(followUps)..add(followUp);
    if (followUpDate == null || followUp.dateTime.isAfter(followUpDate!)) {
      followUpDate = followUp.dateTime;
    }
  }
}
