import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Vazirmatn license and upstream authors are bundled as app assets', () async {
    final license = await rootBundle.loadString(
      'assets/fonts/ui/vazirmatn/LICENSE.txt',
    );
    final authors = await rootBundle.loadString(
      'assets/fonts/ui/vazirmatn/AUTHORS.txt',
    );

    expect(license, contains('SIL OPEN FONT LICENSE Version 1.1'));
    expect(license, contains('Copyright 2015 The Vazirmatn Project Authors'));
    expect(authors, contains('Saber Rastikerdar'));
  });
}
