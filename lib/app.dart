import 'package:flutter/material.dart';
import 'package:cloudvm_real/screens/splash_screen.dart';

class CloudVMApp extends StatelessWidget {
  const CloudVMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CloudVM Real',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4FACFE),
          secondary: Color(0xFF00F2FE),
          surface: Color(0xFF1A1A2E),
          background: Color(0xFF0A0A0F),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
