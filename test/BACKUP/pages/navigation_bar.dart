import 'package:flutter/material.dart';

class NavigationBarApp extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavigationBarApp({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Transações',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Configurações',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.cyan,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
    );
  }
}
