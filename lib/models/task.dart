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
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      note: (json['note'] as String?) ?? '',
      result: json['result'] as String?,
      nextFollowUp: json['nextFollowUp'] == null
          ? null
          : DateTime.parse(json['nextFollowUp'] as String),
    );
  }
}

// مدل اصلی Task با پشتیبانی از تاریخچه پیگیری
class ArvinTask {
  ArvinTask({
    required this.id,
    required this.title,
    this.description = '',
    this.followUpDate, // هنوز نگهش داریم برای backward compatibility
    this.tags = const [],
    this.archived = false,
    this.trashed = false,
    this.completed = false,
    this.followUps = const [], // فیلد جدید
  });

  final String id;
  String title;
  String description;
  DateTime? followUpDate; // ← فعلاً نگه می‌داریم
  List<String> tags;
  bool archived;
  bool trashed;
  bool completed;
  List<FollowUp> followUps; // ← تاریخچه پیگیری‌ها

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
    // ابتدا followUps را از JSON می‌خوانیم (اگر وجود داشته باشد)
    List<FollowUp> loadedFollowUps = [];
    if (json['followUps'] is List) {
      loadedFollowUps = (json['followUps'] as List)
          .map((item) => FollowUp.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    // اگر followUps خالی بود ولی followUpDate قدیمی وجود داشت،
    // یک FollowUp اولیه از آن می‌سازیم (Migration خودکار)
    if (loadedFollowUps.isEmpty && json['followUpDate'] != null) {
      final oldDate = DateTime.tryParse(json['followUpDate'] as String);
      if (oldDate != null) {
        loadedFollowUps = [
          FollowUp(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            dateTime: oldDate,
            note: 'مهاجرت خودکار از تاریخ پیگیری قبلی',
          ),
        ];
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

  // متد کمکی برای گرفتن آخرین پیگیری
  FollowUp? get lastFollowUp =>
      followUps.isNotEmpty ? followUps.last : null;

  // متد کمکی برای گرفتن آخرین تاریخ پیگیری
  DateTime? get lastFollowUpDate => lastFollowUp?.dateTime;
}