import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy JSON without priority remains P4 and round-trips safely', () {
    final task = Task.fromJson({'id': 'legacy', 'title': 'کار قدیمی'});
    expect(task.priority, TaskPriority.none);
    expect(task.toJson()['priority'], 'none');
  });

  test('legacy enum names map to the four Eisenhower levels', () {
    const cases = <String, TaskPriority>{
      'high': TaskPriority.high, 'medium': TaskPriority.medium,
      'low': TaskPriority.low, 'none': TaskPriority.none,
    };
    for (final entry in cases.entries) {
      final task = Task.fromJson({'id': entry.key, 'title': 'قدیمی', 'priority': entry.key});
      expect(task.priority, entry.value);
      expect(task.toJson()['priority'], entry.key);
    }
  });

  test('P1-P4 aliases are accepted and written back as stable legacy values', () {
    const cases = <String, TaskPriority>{
      'P1': TaskPriority.high, 'P2': TaskPriority.medium,
      'P3': TaskPriority.low, 'P4': TaskPriority.none,
    };
    for (final entry in cases.entries) {
      final task = Task.fromJson({'id': entry.key, 'title': 'کار', 'priority': entry.key});
      expect(task.priority, entry.value);
      expect(task.toJson()['priority'], entry.value.name);
    }
  });

  test('unknown or malformed priority values fail soft to P4', () {
    for (final raw in <Object?>['urgent-v2', 99, null]) {
      final task = Task.fromJson({'id': 'future', 'title': 'آینده', if (raw != null) 'priority': raw});
      expect(task.priority, TaskPriority.none);
    }
  });

  test('new Tasks default to P2', () {
    final task = Task(id: 'new', title: 'تازه');
    expect(task.priority, TaskPriority.medium);
    expect(task.toJson()['priority'], 'medium');
  });
}
