import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController secretController = TextEditingController();
  final TextEditingController confirmSecretController = TextEditingController();
  String name = '';
  String email = '';
  String secret = '';
  String confirmSecret = '';

  void setData() {
    name = nameController.text.trim();
    email = emailController.text.trim();
    secret = secretController.text.trim();
    confirmSecret = confirmSecretController.text.trim();
  }

  void register() {
    setData();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um nome válido.')),
      );
      return;
    } else if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um email válido.')),
      );
      return;
    } else if (secret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira uma senha válida.')),
      );
      return;
    } else if (secret.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha deve conter pelo menos 8 caracteres.'),
        ),
      );
      return;
    } else if (secret.contains(RegExp(r'^[a-zA-Z0-9]+$'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha deve conter caracteres especiais.'),
        ),
      );
      return;
    } else if (secret != confirmSecret) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As senhas não coincidem.')));
      return;
    }

    registerConfirm();
    // Salva o nome do usuário no Hive
    Hive.openBox('Users');
    Box box = Hive.box('Users');
    box.put('name', name);

    // Navega para a HomePage
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const HomePage()),
    // );
  }

  void registerConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação de Registro'),
        content: const Text('Deseja realmente registrar este usuário?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o diálogo
            },
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context), // Fecha o diálogo
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: secretController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            TextField(
              controller: confirmSecretController,
              decoration: const InputDecoration(labelText: 'Confirmar Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 50),
            ElevatedButton(onPressed: register, child: const Text('Registrar')),
          ],
        ),
      ),
    );
  }
}
