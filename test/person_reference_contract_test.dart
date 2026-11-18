import 'package:arvin/models/person_reference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PersonReference', () {
    test('normalizes stable identity and offline display label', () {
      final person = PersonReference(
        id: ' person:42 ',
        displayName: ' سارا احمدی ',
      );

      expect(person.id, 'person:42');
      expect(person.displayName, 'سارا احمدی');
    });

    test('rejects empty identity or display label', () {
      expect(
        () => PersonReference(id: '   ', displayName: 'سارا'),
        throwsArgumentError,
      );
      expect(
        () => PersonReference(id: 'person-1', displayName: '   '),
        throwsArgumentError,
      );
    });
  });

  group('TaskPersonContext', () {
    test('associates people by canonical Task id without copying Task payload', () {
      final context = TaskPersonContext(
        taskId: ' task:customer:1 ',
        people: [
          PersonReference(id: 'person-1', displayName: 'سارا'),
          PersonReference(id: 'person-2', displayName: 'علی'),
        ],
      );

      expect(context.taskId, 'task:customer:1');
      expect(context.people.map((person) => person.id), ['person-1', 'person-2']);
    });

    test('supports an empty optional people relation', () {
      final context = TaskPersonContext(taskId: 'task-1');

      expect(context.people, isEmpty);
    });

    test('rejects duplicate Person ids deterministically', () {
      expect(
        () => TaskPersonContext(
          taskId: 'task-1',
          people: [
            PersonReference(id: 'person-1', displayName: 'نام اول'),
            PersonReference(id: 'person-1', displayName: 'نام دوم'),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('exposes an immutable relation list', () {
      final context = TaskPersonContext(
        taskId: 'task-1',
        people: [PersonReference(id: 'person-1', displayName: 'سارا')],
      );

      expect(
        () => context.people.add(
          PersonReference(id: 'person-2', displayName: 'علی'),
        ),
        throwsUnsupportedError,
      );
    });

    test('rejects an empty canonical Task id', () {
      expect(() => TaskPersonContext(taskId: '  '), throwsArgumentError);
    });
  });
}
