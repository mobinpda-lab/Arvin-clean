abstract final class AppFonts {
  static const String vazirmatnFamily = 'Vazirmatn';

  /// System serif is the primary platform fallback for the two approved
  /// sacred Arabic phrases. The ordered family list prefers installed Naskh
  /// faces on Android/web; no other application text uses this exception.
  static const String sacredArabicFamily = 'serif';
  static const List<String> sacredArabicFallback = <String>[
    'Noto Naskh Arabic',
    'Noto Naskh Arabic UI',
    'NotoNaskhArabic',
  ];

  static const Set<String> _approvedSacredPhrases = <String>{
    'بسم الله الرحمن الرحیم',
    'بسم‌الله الرحمن الرحیم',
    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    'أُفَوِّضُ أَمْرِی إِلَى اللَّهِ',
    'افوض امری الی الله',
  };

  /// Returns the platform Naskh-style serif only for the exact owner-approved
  /// sacred phrases. Every other UI string remains bundled Vazirmatn.
  static String familyForText(String text) =>
      _approvedSacredPhrases.contains(text) ? sacredArabicFamily : vazirmatnFamily;

  static bool isApprovedSacredPhrase(String text) =>
      _approvedSacredPhrases.contains(text);
}
