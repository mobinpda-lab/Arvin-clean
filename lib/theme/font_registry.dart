import 'app_fonts.dart';

class ArvinFontOption {
  final String id, nameFa, description, category, fontFamily;
  final bool isAvailableLocally;
  const ArvinFontOption({required this.id, required this.nameFa, required this.description, required this.category, required this.fontFamily, this.isAvailableLocally = false});
  String? get effectiveFontFamily => id == 'system' ? null : (isAvailableLocally ? fontFamily : null);
}

const List<ArvinFontOption> kAvailableArvinFonts = <ArvinFontOption>[
  ArvinFontOption(
    id: 'vazirmatn',
    nameFa: 'وزیرمتن',
    description: 'فونت مدرن و عمومی رابط کاربری',
    category: 'عمومی',
    fontFamily: 'Vazirmatn',
    isAvailableLocally: true,
  ),
  ArvinFontOption(
    id: 'system',
    nameFa: 'فونت دستگاه',
    description: 'فونت پیش‌فرض سیستم؛ بدون نیاز به فایل اضافی',
    category: 'عمومی',
    fontFamily: 'system',
    isAvailableLocally: true,
  ),
  ArvinFontOption(
    id: 'vazirharf',
    nameFa: 'وزیرحرف (پیش‌فرض آروین)',
    description: 'فونت پیش‌فرض آروین؛ در ساخت رسمی از نسخه ثابت‌شده و مجاز دریافت و همراه APK بسته‌بندی می‌شود',
    category: 'عمومی',
    fontFamily: AppFonts.vazirharfFamily,
    isAvailableLocally: true,
  ),
];

ArvinFontOption arvinFontById(String? id) {
  for (final option in kAvailableArvinFonts) {
    if (option.id == id || option.fontFamily == id) return option;
  }
  return kAvailableArvinFonts.last;
}
