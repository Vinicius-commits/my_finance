import 'package:flutter/material.dart';

class TopBar extends AppBar {
  TopBar({super.key, required String title, required Function() onMenuPressed})
    : super(
        title: Text(title),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.cyan,
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ),
      );

  void showMenu() {
    // Implementar a lógica do menu aqui
  }
}
