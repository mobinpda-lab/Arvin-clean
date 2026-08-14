class FollowUp {
  const FollowUp({
    required this.id,
    required this.dateTime,
    this.note = '',
    this.result,
    this.nextFollowUp,
  });

  final String id;
  final DateTime dateTime;
  final String note;
  final String? result;
  final DateTime? nextFollowUp;

  Map<String, dynamic> toJson() => <String, dynamic>{
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
      note: json['note'] as String? ?? '',
      result: json['result'] as String?,
      nextFollowUp: json['nextFollowUp'] == null
          ? null
          : DateTime.parse(json['nextFollowUp'] as String),
    );
  }
}
