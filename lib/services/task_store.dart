import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/follow_up.dart';
import '../models/task.dart';

class TaskStore {
  static const key = 'arvin.tasks';

  Future<List<Task>> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(key);
    if (raw == null) return [];

    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((m) {
      final legacyFollowUpDate = m['followUpDate'] == null
          ? null
          : DateTime.tryParse(m['followUpDate'] as String);

      final rawFollowUps = m['followUps'];
      List<FollowUp> followUps;
      if (rawFollowUps is List) {
        followUps = rawFollowUps
            .whereType<Map>()
            .map((item) => FollowUp.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      } else if (legacyFollowUpDate != null) {
        // Backward compatibility: convert the old single follow-up date into
        // the first history entry without losing the original date.
        followUps = <FollowUp>[
          FollowUp(
            id: '${m['id']}-legacy-follow-up',
            dateTime: legacyFollowUpDate,
          ),
        ];
      } else {
        followUps = <FollowUp>[];
      }

      return Task(
        id: m['id'] as String,
        title: m['title'] as String? ?? '',
        description: m['description'] as String? ?? '',
        followUpDate: legacyFollowUpDate,
        followUps: followUps,
        tags: (m['tags'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        archived: m['archived'] as bool? ?? false,
        trashed: m['trashed'] as bool? ?? false,
        completed: m['completed'] as bool? ?? false,
      );
    }).toList();
  }

  Future<void> save(List<Task> tasks) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      key,
      jsonEncode(
        tasks
            .map(
              (t) => <String, dynamic>{
                'id': t.id,
                'title': t.title,
                'description': t.description,
                'followUpDate': t.followUpDate?.toIso8601String(),
                'followUps': t.followUps.map((f) => f.toJson()).toList(),
                'tags': t.tags,
                'archived': t.archived,
                'trashed': t.trashed,
                'completed': t.completed,
              },
            )
            .toList(),
      ),
    );
  }
}
