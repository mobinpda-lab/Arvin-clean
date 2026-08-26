import 'package:flutter/material.dart';

import 'main.dart' show HomePage;
import 'theme/app_font_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppFontController.instance.initialize();
  runApp(const ArvinTypographyApp());
}

class ArvinTypographyApp extends StatelessWidget {
  const ArvinTypographyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppFontController.instance,
      builder: (context, _, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'مدیریت کارها وپیگیری آروین',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            fontFamily: AppFontController.instance.family,
          ),
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: HomePage(),
          ),
        );
      },
    );
  }
}
