// import 'package:drift/drift.dart';
// import 'package:my_finance/data/local/database.dart'; // Seu banco de dados Drift
import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Se usar Firebase
// import 'package:cloud_firestore/cloud_firestore.dart'; // Se usar Firebase
import 'package:connectivity_plus/connectivity_plus.dart'; // Para NetworkInfo
import 'package:my_finance/core/network/network_info.dart';

part 'app_providers.g.dart'; // Arquivo gerado pelo build_runner

// // Provedor para a instância do banco de dados Drift
// @Riverpod(keepAlive: true)
// AppDatabase appDatabase(AppDatabaseRef ref) {
//   return AppDatabase();
// }

// // Provedor para a instância do Firebase Auth
// @Riverpod(keepAlive: true)
// FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
//   return FirebaseAuth.instance;
// }

// // Provedor para a instância do Cloud Firestore
// @Riverpod(keepAlive: true)
// FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
//   return FirebaseFirestore.instance;
// }

// Provedor para a verificação de conectividade de rede
@Riverpod(keepAlive: true)
NetworkInfo networkInfo(NetworkInfoRef ref) {
  return NetworkInfoImpl(Connectivity());
}