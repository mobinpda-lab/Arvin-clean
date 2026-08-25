import 'package:arvin/models/task.dart';
import 'package:arvin/services/home_search_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const projection = HomeSearchProjection();

  test('returns canonical ids for Persian-normalized and follow-up matches', () {
    final tasks = <Task>[
      Task(id: 'title', title: 'يادداشت كاری'),
      Task(
        id: 'followup',
        title: 'کار دوم',
        followUps: [
          FollowUp(
            id: 'f1',
            dateTime: DateTime(2026, 8, 25),
            note: 'تماس با مشتری',
          ),
        ],
      ),
      Task(id: 'other', title: 'خرید'),
    ];

    expect(projection.matchingIds(tasks, 'یادداشت کاری'), {'title'});
    expect(projection.matchingIds(tasks, 'مشتری'), {'followup'});
    expect(projection.matchingIds(tasks, ''), {'title', 'followup', 'other'});
  });
}
