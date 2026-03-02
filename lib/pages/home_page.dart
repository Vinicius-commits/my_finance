import 'package:flutter/material.dart';
import 'package:my_finance/pages/screen_operations.dart';
import 'package:my_finance/pages/navigation_bar.dart';
import 'package:my_finance/pages/top_bar.dart';
import 'package:my_finance/pages/config_page.dart';

class HomePage extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  const HomePage({super.key, this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Página Inicial',
    'Transações',
    'Configurações',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _bodies = [
      const Center(child: Text('Bem-vindo à Página Inicial!')),
      const OperationsBody(),
      ConfigPage(onThemeChanged: widget.onThemeChanged),
    ];

    return Scaffold(
      appBar: TopBar(
        title: _titles[_currentIndex],
        onMenuPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Menu pressionado na ${_titles[_currentIndex]}'),
            ),
          );
        },
      ),
      body: _bodies[_currentIndex],
      bottomNavigationBar: NavigationBarApp(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
