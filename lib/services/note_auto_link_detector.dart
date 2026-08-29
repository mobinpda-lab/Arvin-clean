enum NoteAutoLinkKind { web, phone }

class NoteAutoLink {
  const NoteAutoLink({
    required this.kind,
    required this.text,
    required this.start,
    required this.end,
    required this.uri,
  });

  final NoteAutoLinkKind kind;
  final String text;
  final int start;
  final int end;
  final Uri uri;
}

/// Pure local detector for optional actionable links inside canonical notes.
///
/// It performs no network access, does not mutate note content and owns no
/// persistence/settings. The Notebook UI can enable/disable use of this
/// detector through the existing Settings foundation.
class NoteAutoLinkDetector {
  const NoteAutoLinkDetector();

  static final RegExp _web = RegExp(
    r'(?:(?:https?://)|(?:www\.))[A-Za-z0-9\-._~:/?#\[\]@!$&\'()*+,;=%]+',
    caseSensitive: false,
  );

  static final RegExp _phone = RegExp(
    r'(?<!\d)(?:\+?98|0)?9\d{9}(?!\d)',
  );

  List<NoteAutoLink> detect(String text) {
    if (text.isEmpty) return const <NoteAutoLink>[];

    final found = <NoteAutoLink>[];

    for (final match in _web.allMatches(text)) {
      final raw = match.group(0)!;
      final normalized = raw.startsWith('www.') ? 'https://$raw' : raw;
      final uri = Uri.tryParse(normalized);
      if (uri == null || !uri.hasScheme || uri.host.isEmpty) continue;
      found.add(
        NoteAutoLink(
          kind: NoteAutoLinkKind.web,
          text: raw,
          start: match.start,
          end: match.end,
          uri: uri,
        ),
      );
    }

    for (final match in _phone.allMatches(text)) {
      if (_overlaps(match.start, match.end, found)) continue;
      final raw = match.group(0)!;
      final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
      final normalized = digits.startsWith('+')
          ? digits
          : digits.startsWith('0')
              ? '+98${digits.substring(1)}'
              : digits.startsWith('98')
                  ? '+$digits'
                  : '+98$digits';
      found.add(
        NoteAutoLink(
          kind: NoteAutoLinkKind.phone,
          text: raw,
          start: match.start,
          end: match.end,
          uri: Uri(scheme: 'tel', path: normalized),
        ),
      );
    }

    found.sort((a, b) {
      final byStart = a.start.compareTo(b.start);
      if (byStart != 0) return byStart;
      return a.end.compareTo(b.end);
    });
    return List<NoteAutoLink>.unmodifiable(found);
  }

  bool _overlaps(int start, int end, List<NoteAutoLink> links) {
    for (final link in links) {
      if (start < link.end && end > link.start) return true;
    }
    return false;
  }
}
