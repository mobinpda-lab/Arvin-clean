import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/simple_note_session_policy.dart';

void main() {
  test('new note session starts editable', () {
    final policy = SimpleNoteSessionPolicy();
    expect(policy.isEditing, isTrue);
    expect(policy.isReadOnly, isFalse);
  });

  test('leaving editor makes the note read-only', () {
    final policy = SimpleNoteSessionPolicy();
    policy.exitEditor();
    expect(policy.isEditing, isFalse);
    expect(policy.isReadOnly, isTrue);
  });

  test('explicit edit action reopens editing mode', () {
    final policy = SimpleNoteSessionPolicy();
    policy.exitEditor();
    policy.requestEdit();
    expect(policy.isEditing, isTrue);
  });
}
