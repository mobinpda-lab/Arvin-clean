import 'package:arvin/models/task.dart';
import 'package:arvin/services/home_task_filter_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home multi-select tags use OR semantics', () {
    final first = Task(id: 'first', title: 'اول', tags: const ['مهم']);
    final second = Task(id: 'second', title: 'دوم', tags: const ['عادی']);
    final both = Task(id: 'both', title: 'هر دو', tags: const ['مهم', 'عادی']);
    final neither = Task(id: 'neither', title: 'هیچ‌کدام', tags: const ['شخصی']);

    const selected = <String>{'مهم', 'عادی'};
    expect(homeTaskMatchesAnySelectedTag(first, selected), isTrue);
    expect(homeTaskMatchesAnySelectedTag(second, selected), isTrue);
    expect(homeTaskMatchesAnySelectedTag(both, selected), isTrue);
    expect(homeTaskMatchesAnySelectedTag(neither, selected), isFalse);
  });

  test('empty Home tag selection leaves every task eligible', () {
    final task = Task(id: 'untagged', title: 'بدون برچسب');
    expect(homeTaskMatchesAnySelectedTag(task, const <String>{}), isTrue);
  });
}
