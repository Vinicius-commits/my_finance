import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserData {
  UserData({this.name, this.currentBalance, this.simuledBalance});
  String? name;
  double? currentBalance;
  double? simuledBalance;
  List<Map<String, dynamic>> transactions = [];
  bool isDev = false;

  void initUserData() async {
    await Hive.initFlutter();
    await Hive.openBox('UserData');
  }

  void cleanUserData() {
    name = null;
    currentBalance = 0.0;
    simuledBalance = 0.0;
    transactions.clear();
    isDev = false;
  }

  ThemeMode themeMode = ThemeMode.dark;
}
