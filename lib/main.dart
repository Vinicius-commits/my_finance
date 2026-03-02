import 'package:flutter/material.dart';
import 'package:my_finance/pages/log_in_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(FinanceApp());
}

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanças Simples',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: _themeMode,
      home: LogInPage(),
    );
  }
}
