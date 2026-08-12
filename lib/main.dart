import 'package:flutter/material.dart';

void main() => runApp(const ArvinApp());

class ArvinApp extends StatelessWidget {
  const ArvinApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'آروین',
        theme: ThemeData(useMaterial3: true),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: Text('آروین')),
            body: Center(
              child: Text(
                'پروژه جدید آروین\nهسته برنامه از صفر ساخته شده است.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
}
