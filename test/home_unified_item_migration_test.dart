import 'package:flutter_test/flutter_test.dart';

import '../lib/models/task.dart';

void main() {
  test('legacy Home task envelope loads as Unified Item without data loss', () {
    final legacy = <String, dynamic>{
      'id': 'legacy-1',
      'title': 'کار قدیمی',
      'description': 'توضیح',
      'followUpDate': '2026-08-15T09:30:00.000',
      'tags': ['آروین', 'پیگیری'],
      'archived': false,
      'trashed': false,
      'completed': false,
    };

    final task = Task.fromJson(legacy);

    expect(task.id, 'legacy-1');
    expect(task.title, 'کار قدیمی');
    expect(task.description, 'توضیح');
    expect(task.tags, ['آروین', 'پیگیری']);
    expect(task.followUps, hasLength(1));
    expect(task.lastFollowUpDate, DateTime.parse(legacy['followUpDate'] as String));
    expect(task.archived, isFalse);
    expect(task.trashed, isFalse);
    expect(task.completed, isFalse);
  });

  test('Unified Item serializes migrated FollowUp while preserving legacy date', () {
    final task = Task.fromJson({
      'id': 'legacy-2',
      'title': 'پیگیری',
      'followUpDate': '2026-08-16T10:00:00.000',
    });

    final json = task.toJson();

    expect(json['id'], 'legacy-2');
    expect(json['followUpDate'], '2026-08-16T10:00:00.000');
    expect(json['followUps'], isA<List<dynamic>>());
    expect((json['followUps'] as List).length, 1);
  });
}
