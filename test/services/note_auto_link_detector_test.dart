import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/note_auto_link_detector.dart';

void main() {
  const detector = NoteAutoLinkDetector();

  test('detects http and www links locally in source order', () {
    final links = detector.detect(
      'اول https://example.com/a?q=1 و بعد www.example.org/page',
    );

    expect(links, hasLength(2));
    expect(links[0].kind, NoteAutoLinkKind.web);
    expect(links[0].text, 'https://example.com/a?q=1');
    expect(links[0].uri.toString(), 'https://example.com/a?q=1');
    expect(links[1].kind, NoteAutoLinkKind.web);
    expect(links[1].text, 'www.example.org/page');
    expect(links[1].uri.toString(), 'https://www.example.org/page');
  });

  test('detects Iranian mobile number and normalizes tel uri', () {
    final links = detector.detect('تماس: 09121234567');

    expect(links, hasLength(1));
    expect(links.single.kind, NoteAutoLinkKind.phone);
    expect(links.single.text, '09121234567');
    expect(links.single.uri.toString(), 'tel:+989121234567');
  });

  test('does not mutate text or perform detection when there is no link', () {
    const text = 'یادداشت معمولی بدون نشانی یا شماره';
    expect(detector.detect(text), isEmpty);
    expect(text, 'یادداشت معمولی بدون نشانی یا شماره');
  });

  test('returns deterministic mixed links in source order', () {
    final links = detector.detect(
      '09121234567 سپس https://arvin.example و 989131234567',
    );

    expect(links.map((item) => item.kind), [
      NoteAutoLinkKind.phone,
      NoteAutoLinkKind.web,
      NoteAutoLinkKind.phone,
    ]);
    expect(links.last.uri.toString(), 'tel:+989131234567');
  });
}
