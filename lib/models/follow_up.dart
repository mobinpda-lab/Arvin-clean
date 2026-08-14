/// Follow-up history record for an Arvin task.
///
/// Kept in its own file so UI, services, and tests can depend on the
/// FollowUp model without importing the larger task model.
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

  factory FollowUp.fromJson(Map<String, dynamic> json) => FollowUp(
        id: json['id'] as String? ?? '',
        dateTime: DateTime.parse(json['dateTime'] as String),
        note: json['note'] as String? ?? '',
        result: json['result'] as String?,
        nextFollowUp: json['nextFollowUp'] == null
            ? null
            : DateTime.parse(json['nextFollowUp'] as String),
      );
}
