import 'package:flutter/material.dart';
import 'screens/scan_screen.dart'; // Importing your ScanScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Radar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Optional: Dark theme for radar vibe
      home: const ScanScreen(), // Set ScanScreen as the home screen
    );
  }
}
