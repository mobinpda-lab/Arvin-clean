import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy Task JSON defaults to no priority', () {
    final task = Task.fromJson({
      'id': 'legacy',
      'title': 'کار قدیمی',
    });

    expect(task.priority, TaskPriority.none);
    expect(task.toJson().containsKey('priority'), isFalse);
  });

  test('Task priority round-trips through canonical JSON', () {
    final original = Task(
      id: 'priority',
      title: 'کار مهم',
      priority: TaskPriority.high,
    );

    final json = original.toJson();
    final restored = Task.fromJson(json);

    expect(json['priority'], 'high');
    expect(restored.priority, TaskPriority.high);
    expect(restored.id, original.id);
  });

  test('unknown priority fails soft to none for forward compatibility', () {
    final task = Task.fromJson({
      'id': 'future',
      'title': 'کار آینده',
      'priority': 'urgent-v2',
    });

    expect(task.priority, TaskPriority.none);
  });
}
