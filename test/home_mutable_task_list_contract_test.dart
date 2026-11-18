import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home copies migration results into a mutable canonical Task list', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(mainSource, contains('tasks = List<Task>.of(value);'));
    expect(mainSource, isNot(contains('tasks = value;')));
  });
}
