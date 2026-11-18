import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/core/storage/task_store.dart';

class _FakeTaskStore implements TaskStore<String> {
  List<String> items = const [];

  @override
  Future<List<String>> load() async => List<String>.of(items);

  @override
  Future<void> save(List<String> items) async {
    this.items = List<String>.of(items);
  }
}

void main() {
  test('storage boundary supports independent load and save operations', () async {
    final store = _FakeTaskStore();

    await store.save(['one', 'two']);

    expect(await store.load(), ['one', 'two']);
  });
}
