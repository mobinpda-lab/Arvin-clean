import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/tag_store.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  test('TagStore facade reads and mutates only the canonical SQLite catalog',
      () async {
    const legacyTags = <String>[' قدیمی ', 'قدیمی'];
    SharedPreferences.setMockInitialValues(<String, Object>{
      'arvin.tags': legacyTags,
    });
    final directory =
        await Directory.systemTemp.createTemp('arvin-tag-store-facade-');
    final databaseFile = File('${directory.path}/arvin.sqlite');
    var database = NativeDatabase(databaseFile);

    try {
      var store = TaskStore(executor: database);
      var tags = TagStore(store: store);

      expect(await tags.load(), ['قدیمی']);
      await tags.add('جدید');
      await store.save(<Task>[
        Task(id: 'tag-owner', title: 'کار دارای برچسب', tags: ['مصرف‌شده']),
      ]);
      await tags.add('مصرف‌شده');

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getStringList('arvin.tags'), legacyTags);

      await expectLater(
        tags.remove('مصرف‌شده'),
        throwsA(isA<TaskTaxonomyDeleteBlocked>()),
      );
      expect(await tags.load(), contains('مصرف‌شده'));

      await tags.remove('جدید');
      expect(await tags.load(), isNot(contains('جدید')));

      await database.close();
      database = NativeDatabase(databaseFile);
      store = TaskStore(executor: database);
      tags = TagStore(store: store);
      expect(await tags.load(), containsAll(['قدیمی', 'مصرف‌شده']));
      expect((await store.load()).single.tags, ['مصرف‌شده']);
      expect(preferences.getStringList('arvin.tags'), legacyTags);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}
