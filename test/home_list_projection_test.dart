import 'package:arvin/models/task.dart';
import 'package:arvin/services/home_list_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = HomeListProjection();
  final now = DateTime(2026, 8, 28, 16);

  Task task(
    String id, {
    String? title,
    DateTime? dueDate,
    DateTime? followUpDate,
    bool followUpEnabled = false,
    bool completed = false,
    bool archived = false,
    bool trashed = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<FollowUp> followUps = const [],
  }) =>
      Task(
        id: id,
        title: title ?? id,
        dueDate: dueDate,
        followUpDate: followUpDate,
        followUpEnabled: followUpEnabled,
        completed: completed,
        archived: archived,
        trashed: trashed,
        createdAt: createdAt,
        updatedAt: updatedAt,
        followUps: followUps,
      );

  test('all notes and follow-up scopes reuse canonical items', () {
    final note = task('note');
    final tracked = task('tracked', followUpEnabled: true);
    final history = task(
      'history',
      followUps: [FollowUp(id: 'fu', dateTime: now)],
    );
    final archived = task('archived', archived: true);

    expect(
      projection
          .project(
            [note, tracked, history, archived],
            scope: HomeListScope.all,
            sort: HomeListSort.title,
          )
          .map((item) => item.id),
      ['history', 'note', 'tracked'],
    );
    expect(
      projection
          .project(
            [note, tracked, history],
            scope: HomeListScope.notes,
            sort: HomeListSort.title,
          )
          .map((item) => item.id),
      ['note'],
    );
    expect(
      projection
          .project(
            [note, tracked, history],
            scope: HomeListScope.followUpEnabled,
            sort: HomeListSort.title,
          )
          .map((item) => item.id),
      ['history', 'tracked'],
    );
  });

  test('today future and overdue use Task due date before legacy follow-up', () {
    final tasks = [
      task(
        'today-due',
        dueDate: DateTime(2026, 8, 28, 9),
        followUpDate: DateTime(2026, 8, 30, 9),
      ),
      task('future', dueDate: DateTime(2026, 8, 29, 9)),
      task('overdue', dueDate: DateTime(2026, 8, 27, 23)),
      task(
        'legacy-fallback',
        followUpDate: DateTime(2026, 8, 28, 20),
        followUpEnabled: true,
      ),
      task(
        'completed-old',
        dueDate: DateTime(2026, 8, 27, 8),
        completed: true,
      ),
    ];

    expect(
      projection
          .project(
            tasks,
            scope: HomeListScope.today,
            sort: HomeListSort.title,
            now: now,
          )
          .map((item) => item.id),
      ['legacy-fallback', 'today-due'],
    );
    expect(
      projection
          .project(
            tasks,
            scope: HomeListScope.future,
            sort: HomeListSort.title,
            now: now,
          )
          .map((item) => item.id),
      ['future'],
    );
    expect(
      projection
          .project(
            tasks,
            scope: HomeListScope.overdue,
            sort: HomeListSort.title,
            now: now,
          )
          .map((item) => item.id),
      ['overdue'],
    );
  });

  test('date sort puts undated items last and reverses deterministically', () {
    final tasks = [
      task('b', dueDate: DateTime(2026, 8, 29)),
      task('none'),
      task('a', dueDate: DateTime(2026, 8, 28)),
    ];

    expect(
      projection
          .project(
            tasks,
            scope: HomeListScope.all,
            sort: HomeListSort.date,
          )
          .map((item) => item.id),
      ['a', 'b', 'none'],
    );
    expect(
      projection
          .project(
            tasks,
            scope: HomeListScope.all,
            sort: HomeListSort.date,
            ascending: false,
          )
          .map((item) => item.id),
      ['none', 'b', 'a'],
    );
  });

  test('latest sort uses newest meaningful update including FollowUp history', () {
    final tasks = [
      task('created', createdAt: DateTime(2026, 8, 20)),
      task('updated', updatedAt: DateTime(2026, 8, 25)),
      task(
        'followup',
        updatedAt: DateTime(2026, 8, 22),
        followUps: [
          FollowUp(id: 'fu', dateTime: DateTime(2026, 8, 27)),
        ],
      ),
    ];

    expect(
      projection
          .project(
            tasks,
            scope: HomeListScope.all,
            sort: HomeListSort.latest,
            ascending: false,
          )
          .map((item) => item.id),
      ['followup', 'updated', 'created'],
    );
  });

  test('projection excludes archived and trashed without mutating input', () {
    final active = task('active');
    final tasks = [active, task('archived', archived: true), task('trash', trashed: true)];

    final result = projection.project(
      tasks,
      scope: HomeListScope.all,
      sort: HomeListSort.title,
    );

    expect(result.map((item) => item.id), ['active']);
    expect(identical(result.single, active), isTrue);
    expect(tasks, hasLength(3));
  });
}
