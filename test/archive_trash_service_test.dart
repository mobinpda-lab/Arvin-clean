import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/services/archive_trash_service.dart';

class Item {
  bool archived = false;
  bool trashed = false;
}

void main() {
  test('restore clears archived and trashed states', () {
    final item = Item()
      ..archived = true
      ..trashed = true;
    const service = ArchiveTrashService<Item>();

    service.restore(
      item,
      clearArchived: (value) => value.archived = false,
      clearTrashed: (value) => value.trashed = false,
    );

    expect(item.archived, isFalse);
    expect(item.trashed, isFalse);
  });
}
