import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DfdApp());
}

class DfdApp extends StatelessWidget {
  const DfdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DFD Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1A237E),
        useMaterial3: true,
      ),
      // Adicione estas 3 linhas:
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      home: const HomeScreen(),
    );
  }
}