import 'package:flutter/material.dart';

import 'main.dart' show HomePage;
import 'theme/app_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppFonts.loadLicensedIranSansX();
  runApp(const ArvinIranSansApp());
}

class ArvinIranSansApp extends StatelessWidget {
  const ArvinIranSansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدیریت کارها وپیگیری آروین',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: AppFonts.family,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(),
      ),
    );
  }
}
