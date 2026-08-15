import 'recurrence.dart';

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
          : DateTime.tryParse(json['nextFollowUp'] as String),
    );
  }
}

/// Unified product model foundation:
/// an Item can behave as a simple note until follow-up is enabled.
/// These fields are additive and remain backward-compatible with legacy data.
class Task {
  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.createdAt,
    this.updatedAt,
    this.followUpEnabled = false,
    this.followUpDate,
    this.tags = const [],
    this.category,
    this.checklist = const [],
    this.reminderDate,
    this.archived = false,
    this.trashed = false,
    this.completed = false,
    this.followUps = const [],
    this.recurrence,
  });

  final String id;
  String title;
  String description;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool followUpEnabled;
  DateTime? followUpDate;
  List<String> tags;
  String? category;
  List<String> checklist;
  DateTime? reminderDate;
  bool archived;
  bool trashed;
  bool completed;
  List<FollowUp> followUps;
  RecurrenceRule? recurrence;

  bool get isSimpleNote => !followUpEnabled && followUps.isEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'followUpEnabled': followUpEnabled,
        'followUpDate': followUpDate?.toIso8601String(),
        'tags': tags,
        'category': category,
        'checklist': checklist,
        'reminderDate': reminderDate?.toIso8601String(),
        'archived': archived,
        'trashed': trashed,
        'completed': completed,
        'followUps': followUps.map((e) => e.toJson()).toList(),
        if (recurrence != null) 'recurrence': recurrence!.toJson(),
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    var loadedFollowUps = <FollowUp>[];
    if (json['followUps'] is List) {
      loadedFollowUps = (json['followUps'] as List)
          .map((item) => FollowUp.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    if (loadedFollowUps.isEmpty && json['followUpDate'] != null) {
      final oldDate = DateTime.tryParse(json['followUpDate'] as String);
      if (oldDate != null) {
        loadedFollowUps = [
          FollowUp(
            id: oldDate.microsecondsSinceEpoch.toString(),
            dateTime: oldDate,
            note: 'مهاجرت خودکار از تاریخ پیگیری قبلی',
          ),
        ];
      }
    }

    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] == null ? null : DateTime.tryParse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null ? null : DateTime.tryParse(json['updatedAt'] as String),
      followUpEnabled: json['followUpEnabled'] as bool? ?? loadedFollowUps.isNotEmpty,
      followUpDate: json['followUpDate'] == null ? null : DateTime.tryParse(json['followUpDate'] as String),
      tags: (json['tags'] as List<dynamic>? ?? const []).whereType<String>().toList(),
      category: json['category'] as String?,
      checklist: (json['checklist'] as List<dynamic>? ?? const []).whereType<String>().toList(),
      reminderDate: json['reminderDate'] == null ? null : DateTime.tryParse(json['reminderDate'] as String),
      archived: json['archived'] as bool? ?? false,
      trashed: json['trashed'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
      followUps: loadedFollowUps,
      recurrence: json['recurrence'] is Map
          ? RecurrenceRule.fromJson(Map<String, dynamic>.from(json['recurrence'] as Map))
          : null,
    );
  }

  FollowUp? get lastFollowUp => followUps.isNotEmpty ? followUps.last : null;

  DateTime? get lastFollowUpDate => lastFollowUp?.dateTime;
}
