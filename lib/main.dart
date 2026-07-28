import 'constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/dashboard_screen.dart';

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
        colorSchemeSeed: AppColors.primary,
        useMaterial3: true,
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      home: const DashboardScreen(),
    );
  }
}