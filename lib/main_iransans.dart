import 'package:flutter/material.dart';

import 'main.dart' show HomePage;
import 'theme/app_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasLicensedIranSansX = await AppFonts.loadLicensedIranSansX();
  runApp(ArvinTypographyApp(hasLicensedIranSansX: hasLicensedIranSansX));
}

class ArvinTypographyApp extends StatelessWidget {
  const ArvinTypographyApp({
    required this.hasLicensedIranSansX,
    super.key,
  });

  final bool hasLicensedIranSansX;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدیریت کارها وپیگیری آروین',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: hasLicensedIranSansX
            ? AppFonts.iranSansXFamily
            : AppFonts.vazirmatnFamily,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(),
      ),
    );
  }
}
