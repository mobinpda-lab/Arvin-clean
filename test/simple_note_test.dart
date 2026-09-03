import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/simple_note.dart';

void main() {
  test('SimpleNote keeps editable date and time as one DateTime value', () {
    final note = SimpleNote(
      id: 'n1',
      title: 'موضوع',
      body: 'متن یادداشت',
      dateTime: DateTime(2026, 8, 14, 19, 30),
    );

    final restored = SimpleNote.fromJson(note.toJson());

    expect(restored.title, 'موضوع');
    expect(restored.body, 'متن یادداشت');
    expect(restored.dateTime, note.dateTime);
  });
}
