import 'package:flutter/material.dart';

class ConfigPage extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  const ConfigPage({super.key, this.onThemeChanged});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  static bool isDarkMode = true;

  void toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
    // Passa a mudança para o app principal
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(value ? ThemeMode.dark : ThemeMode.light);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dark_mode, color: Colors.deepPurple),
              Text(textAlign: TextAlign.center, 'Noturno'),
              Switch(
                value: isDarkMode,
                onChanged: ((value) {
                  toggleDarkMode(value);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
