class FollowUp {
  FollowUp({
    required this.id,
    required this.dateTime,
    this.description = '',
    this.result = '',
    this.nextFollowUp,
  });

  final String id;
  final DateTime dateTime;
  final String description;
  final String result;
  final DateTime? nextFollowUp;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'description': description,
        'result': result,
        'nextFollowUp': nextFollowUp?.toIso8601String(),
      };

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      description: json['description'] as String? ?? '',
      result: json['result'] as String? ?? '',
      nextFollowUp: json['nextFollowUp'] == null
          ? null
          : DateTime.parse(json['nextFollowUp'] as String),
    );
  }
}
