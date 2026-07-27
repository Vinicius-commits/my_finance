import 'package:connectivity_plus/connectivity_plus.dart';

/// Lança [Exception] com mensagem amigável se não houver conectividade.
Future<void> assertDeviceOnline() async {
  final result = await Connectivity().checkConnectivity();
  if (result == ConnectivityResult.none) {
    throw Exception(
      'Sem conexão com a internet. Ative Wi‑Fi ou dados móveis e tente de novo.',
    );
  }
}
