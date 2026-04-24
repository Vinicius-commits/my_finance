import 'package:flutter/material.dart';

class SaldoCard extends StatelessWidget {
  final String titulo;
  final double saldo;

  SaldoCard({required this.titulo, required this.saldo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(titulo, style: TextStyle(fontSize: 18)),
            Text(
              'R\$ ${saldo.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String description;
  final double value;
  final String type;

  TransactionTile({
    required this.description,
    required this.value,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(description),
      subtitle: Text(type),
      trailing: Text(
        'R\$ ${value.toStringAsFixed(2)}',
        style: TextStyle(color: type == 'revenue' ? Colors.green : Colors.red),
      ),
    );
  }
}
