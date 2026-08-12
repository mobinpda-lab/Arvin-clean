import 'package:flutter/material.dart';

void main() => runApp(const ArvinApp());

class ArvinApp extends StatelessWidget {
  const ArvinApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'مدیریت کارها وپیگیری آروین',
        theme: ThemeData(useMaterial3: true),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: HomePage(),
        ),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text('مدیریت کارها وپیگیری آروین', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        body: const Center(
          child: Text('پروژه جدید آروین\nهسته برنامه از صفر ساخته شده است.', textAlign: TextAlign.center),
        ),
      );
}
