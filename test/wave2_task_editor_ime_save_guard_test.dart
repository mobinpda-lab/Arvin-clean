import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical Task editor title uses IME submit to save and guards duplicates', () {
    final source = File('lib/task_editor_dialog.dart').readAsStringSync();

    expect(source, contains('textInputAction: TextInputAction.done'));
    expect(source, contains('onSubmitted: (_) => _save()'));
    expect(source, contains('bool _saving = false;'));
    expect(source, contains('if (_saving) return;'));
  });
}
