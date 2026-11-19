import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  test('today focus selection survives file-backed SQLite close and reopen and can be removed', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final directory = await Directory.systemTemp.createTemp('arvin-today-focus-');
    final file = File('${directory.path}/focus.sqlite');
    NativeDatabase? firstExecutor;
    NativeDatabase? secondExecutor;
    NativeDatabase? thirdExecutor;
    try {
      firstExecutor = NativeDatabase(file);
      await TaskStore(executor: firstExecutor).save([
        Task(
          id: 'focus-persist',
          title: 'کار برگزیده',
          isSelectedForToday: true,
          isFavorite: false,
        ),
      ]);
      await firstExecutor.close();
      firstExecutor = null;

      secondExecutor = NativeDatabase(file);
      final loaded = await TaskStore(executor: secondExecutor).load();
      expect(loaded.single.isSelectedForToday, isTrue);
      expect(loaded.single.isFavorite, isFalse);

      loaded.single.isSelectedForToday = false;
      await TaskStore(executor: secondExecutor).save(loaded);
      await secondExecutor.close();
      secondExecutor = null;

      thirdExecutor = NativeDatabase(file);
      final reopened = await TaskStore(executor: thirdExecutor).load();
      expect(reopened.single.isSelectedForToday, isFalse);
      expect(reopened.single.isFavorite, isFalse);
    } finally {
      await firstExecutor?.close();
      await secondExecutor?.close();
      await thirdExecutor?.close();
      await directory.delete(recursive: true);
    }
  });
}
