import 'package:flutter/material.dart';

/// A readable, screenshot-friendly diagnostic screen for uncaught Dart and
/// Flutter startup/runtime exceptions. It cannot intercept native process
/// crashes such as SIGSEGV or fatal JVM exceptions.
class StartupCrashScreen extends StatelessWidget {
  const StartupCrashScreen({
    super.key,
    required this.errorText,
    required this.stackTrace,
  });

  final String errorText;
  final String stackTrace;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red.shade900,
          title: const Text('گزارش خطای آروین'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'برنامه با یک خطای پیش‌بینی‌نشده روبه‌رو شد. لطفاً از این صفحه اسکرین‌شات بگیرید و ارسال کنید.',
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'متن کامل خطا',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    errorText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Stack trace',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    stackTrace,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      height: 1.35,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
