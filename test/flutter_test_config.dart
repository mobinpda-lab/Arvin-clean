import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/task_store.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    await TaskStore.resetTestDatabase();
  });
  await testMain();
}
