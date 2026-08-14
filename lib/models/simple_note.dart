import 'dart:convert';

class SimpleNote {
  SimpleNote({
    required this.id,
    required this.title,
    required this.body,
    required this.dateTime,
  });

  final String id;
  String title;
  String body;
  DateTime dateTime;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'dateTime': dateTime.toIso8601String(),
      };

  factory SimpleNote.fromJson(Map<String, dynamic> json) {
    return SimpleNote(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      dateTime: DateTime.tryParse(json['dateTime'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

String encodeSimpleNotes(List<SimpleNote> notes) =>
    jsonEncode(notes.map((note) => note.toJson()).toList());
