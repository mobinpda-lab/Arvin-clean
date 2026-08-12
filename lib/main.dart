import 'package:flutter/material.dart';

void main() => runApp(const ArvinApp());

class ArvinApp extends StatelessWidget {
  const ArvinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدیریت کارها وپیگیری آروین',
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Column(
          children: [
            Text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ', style: TextStyle(fontSize: 13)),
            Text('مدیریت کارها وپیگیری آروین'),
          ],
        ),
      ),
      body: const Center(
        child: Text('پروژه آروین آماده توسعه است'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.add),
      ),
    );
  }
}
