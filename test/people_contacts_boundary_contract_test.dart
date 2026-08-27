import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('People audit does not introduce standalone persistence or repository', () {
    final productionSources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');

    const forbidden = <String>[
      'arvin.people',
      'arvin.contacts',
      'class PeopleRepository',
      'class PersonRepository',
      'class ContactsRepository',
      'class ContactRepository',
    ];

    for (final marker in forbidden) {
      expect(
        productionSources,
        isNot(contains(marker)),
        reason: 'People/Contacts audit must not add standalone storage: $marker',
      );
    }
  });
}
