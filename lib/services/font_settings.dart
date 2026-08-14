enum ArvinFontChoice { system, vazirmatn, sahel, shabnam }

class ArvinFontSettings {
  const ArvinFontSettings({this.choice = ArvinFontChoice.system});

  final ArvinFontChoice choice;

  String get fontFamily {
    switch (choice) {
      case ArvinFontChoice.system:
        return '';
      case ArvinFontChoice.vazirmatn:
        return 'Vazirmatn';
      case ArvinFontChoice.sahel:
        return 'Sahel';
      case ArvinFontChoice.shabnam:
        return 'Shabnam';
    }
  }

  ArvinFontSettings copyWith({ArvinFontChoice? choice}) =>
      ArvinFontSettings(choice: choice ?? this.choice);
}
