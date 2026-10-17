import 'package:flutter/material.dart';

import 'screens/benchmark_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolate Lab • Chủ đề 03',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff087f8c)),
        scaffoldBackgroundColor: const Color(0xfff3f6f8),
      ),
      home: const BenchmarkPage(),
    );
  }
}
