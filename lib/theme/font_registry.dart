class ArvinFontOption {
  final String id;
  final String nameFa;
  final String description;
  final String category;
  final String? fontFamily;

  const ArvinFontOption({
    required this.id,
    required this.nameFa,
    required this.description,
    required this.category,
    required this.fontFamily,
  });

  String? get effectiveFontFamily => fontFamily;
}

const ArvinFontOption _vazirmatn = ArvinFontOption(
  id: 'vazirmatn',
  nameFa: 'وزیرمتن',
  description: 'فونت رسمی و پیش‌فرض رابط کاربری آروین',
  category: 'رسمی',
  fontFamily: 'Vazirmatn',
);

const ArvinFontOption _systemDefault = ArvinFontOption(
  id: 'system-default',
  nameFa: 'فونت پیش‌فرض سیستم',
  description: 'انتخاب اختیاری برای دسترس‌پذیری؛ نه فونت برند آروین',
  category: 'دسترس‌پذیری',
  fontFamily: null,
);

const List<ArvinFontOption> kAvailableArvinFonts = <ArvinFontOption>[
  _vazirmatn,
  _systemDefault,
];

ArvinFontOption arvinFontById(String? id) =>
    id == _systemDefault.id ? _systemDefault : _vazirmatn;
