// Exemplo de app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seu_app/core/providers/app_providers.dart'; // Para authStateChangesProvider
import 'package:seu_app/features/auth/presentation/pages/login_page.dart';
import 'package:seu_app/features/dashboard/presentation/pages/dashboard_page.dart'; // Exemplo de tela principal

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: 'Meu App Financeiro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: authState.when(
        data: (user) =>
            user == null ? const LoginPage() : const DashboardPage(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) =>
            Scaffold(body: Center(child: Text('Erro: $err'))),
      ),
      routes: {
        // Defina rotas nomeadas aqui, se necessário
        '/login': (context) => const LoginPage(),
        '/home': (context) => const DashboardPage(),
        // ... outras rotas
      },
    );
  }
}
