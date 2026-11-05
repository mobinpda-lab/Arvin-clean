abstract final class AppFonts {
  static const String vazirmatnFamily = 'Vazirmatn';

  /// Android's Naskh-style serif fallback is reserved exclusively for the
  /// two owner-approved sacred Arabic phrases. All other UI uses Vazirmatn.
  static const String sacredArabicFamily = 'serif';

  static const Set<String> _approvedSacredPhrases = <String>{
    'بسم الله الرحمن الرحیم',
    'بسم‌الله الرحمن الرحیم',
    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    'أُفَوِّضُ أَمْرِی إِلَى اللَّهِ',
    'افوض امری الی الله',
  };

  /// Returns Naskh only for the exact owner-approved sacred phrases.
  /// Every other UI string, including Persian copy, remains Vazirmatn.
  static String familyForText(String text) =>
      _approvedSacredPhrases.contains(text) ? sacredArabicFamily : vazirmatnFamily;
}
