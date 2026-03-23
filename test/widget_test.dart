import 'dart:io';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:my_finance/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:my_finance/pages/log_in_page.dart';
import 'package:my_finance/core/providers/app_providers.dart';
import 'package:my_finance/main.dart';

void main() async {
  // print('Start');
  // await delay(5);
  // print(1);
  // await delay(4);
  // print(2);
  // await delay(3);
  // print(3);
  // await delay(20);
  // print(4);

  // countStream(5).listen(
  //   (val) {
  //     print(val);
  //   },
  //   onDone: () {
  //     print('Done');
  //   },
  // );
  // AppInterface appInterface = AppInterface();
  // String option = '';

  // chooseInitialOption(option, appInterface);
  runApp(const FinanceApp());
}

bool chooseInitialOption(String option, AppInterface appInterface) {
  bool choosedCorrectly = true;
  appInterface.initialActionsPanel();
  option = stdin.readLineSync() ?? '';
  switch (option) {
    case '1':
      print('Login selected');
      appInterface.loginPanel();
      break;
    case '2':
      print('Register selected');
      appInterface.registerPanel();
      break;
    case 'X':
      print('Logout selected');
      appInterface.logoutPanel();
      exit(0);

    default:
      print('Invalid option');
      choosedCorrectly = false;
      break;
  }

  if (!choosedCorrectly) {
    return chooseInitialOption(option, appInterface);
  } else {
    return choosedCorrectly;
  }
}

bool chooseUserOption(String option, AppInterface appInterface) {
  bool choosedCorrectly = true;
  appInterface.userPanel();
  option = stdin.readLineSync() ?? '';
  switch (option) {
    case '1':
      print('See balance selected');
      appInterface.sawBalance();
      break;
    case '2':
      print('Add value selected');
      double value = stdin.readLineSync() != null
          ? double.parse(stdin.readLineSync()!)
          : 0.0;
      if (value == 0.0) {
        print('Invalid value');
        return chooseUserOption(option, appInterface);
      }
      appInterface.user?.addValue(value, appInterface.moeda);
      break;
    case '3':
      print('Remove value selected');
      double value = stdin.readLineSync() != null
          ? double.parse(stdin.readLineSync()!)
          : 0.0;

      if (value == 0.0) {
        print('Invalid value');
        return chooseUserOption(option, appInterface);
      }
      break;
    case 'X':
      print('Exit selected');
      chooseInitialOption(option, appInterface);
    default:
      print('Invalid option');
      choosedCorrectly = false;
      break;
  }

  if (!choosedCorrectly) {
    return chooseUserOption(option, appInterface);
  } else {
    return choosedCorrectly;
  }
}

Future trasactionDelay(int seconds) {
  return Future.delayed(Duration(seconds: seconds), () async {
    return;
  });
}

class User {
  String name;
  String password = '';
  List<Transacao> transfers = [];

  double balance = 0.0;

  User({required this.name, required this.password});

  void addValue(double value, Moeda moeda) {
    balance += value;
    transfers.add(Transacao(value: value, moeda: moeda));
  }
}

class AppInterface {
  User? user;
  Moeda moeda = Moeda.real;

  void login(String username, String password) {
    // Simulate login logic
    print('Logging in with username: $username and password: $password');
  }

  void register(String username, String password) {
    // Simulate registration logic
    print('Registering user with username: $username and password: $password');
  }

  void logout() {
    print('Logging out user: ${user?.name}');
    user = null;
  }

  void initialActionsPanel() {
    print('''Displaying actions panel
    1. Login
    2. Register
    X. Logout
    ''');
  }

  void loginPanel() {
    print('Enter username:');
    String username = stdin.readLineSync() ?? '';
    print('Enter password:');
    String password = stdin.readLineSync() ?? '';
    login(username, password);

    user = User(name: username, password: password);

    chooseUserOption('', this);
  }

  void registerPanel() {
    print('Enter username:');
    String username = stdin.readLineSync() ?? '';
    print('Enter password:');
    String password = stdin.readLineSync() ?? '';
    register(username, password);

    user = User(name: username, password: password);

    chooseUserOption('', this);
  }

  void logoutPanel() {
    logout();
  }

  void userPanel() {
    print('''Escolha o que fazer na sua conta
    1. Ver saldo
    2. Adicionar valor
    3. Remover valor
    X. Sair
    ''');
  }

  void sawBalance() {
    print('Seu saldo é: ${moeda.symbol} ${user?.balance}');
  }
}

enum Moeda implements Comparable<Moeda> {
  dollar(symbol: "\$"),
  euro(symbol: "€"),
  real(symbol: "BRL"),
  none(symbol: "NONE");

  const Moeda({required this.symbol});

  final String symbol;

  @override
  int compareTo(Moeda other) {
    return this.index.compareTo(other.index);
  }
}

class Transacao {
  double value;
  Moeda moeda = Moeda.none;
  DateTime date = DateTime.now();

  Transacao({this.value = 0.0, this.moeda = Moeda.real}) {
    date = DateTime.now();
  }
}

Future delay(int seconds) {
  return Future.delayed(Duration(seconds: seconds), () async {
    return;
  });
}

Stream<int> countStream(int to) async* {
  for (int i = 1; i <= to; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}
