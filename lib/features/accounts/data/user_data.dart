import 'package:flutter/material.dart';

class UserData {
  UserData(this.name, {this.currentBalance});
  String name;
  double? currentBalance;
  List<Map<String, dynamic>> transactions = [];
  bool isDev = false;

  void initUserData() async {}

  void cleanUserData() {
    name = '';
    currentBalance = 0.0;
    transactions.clear();
    isDev = false;
  }

  ThemeMode themeMode = ThemeMode.dark;
}
