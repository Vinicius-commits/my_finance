/// Exemplo de uso do enum TransactionTipo em todo o projeto
/// Delete este arquivo quando entender o padrão

import 'package:my_finance/core/exports.dart';
import 'package:my_finance/infrastructure/models/finance_models.dart';
import 'lancamento_tipo_extension.dart';

class ExemploUsoDados {
  void exemploEntity() {
    final lancamento = Transaction(
      id: 'L1',
      description: 'Venda de Produtos',
      value: 1500.00,
      date: DateTime.now(),
      type: TransactionType.revenue,
      accountId: 'C1',
    );

    print('Tipo: ${lancamento.type}');
  }

  void exemploModel() {
    final model = TransactionModel(
      id: 'L1',
      description: 'Compra de Estoque',
      value: 500.00,
      date: DateTime.now(),
      type: TransactionType.expense,
      accountId: 'C1',
    );

    final lancamento = Transaction(
      id: model.id,
      description: model.description,
      value: model.value,
      date: model.date,
      type: model.type,
      accountId: model.accountId,
    );

    final modelParaBanco = TransactionModel(
      id: lancamento.id,
      description: lancamento.description,
      value: lancamento.value,
      date: lancamento.date,
      type: TransactionType.expense,
      accountId: lancamento.accountId,
    );
  }

  void exemploWidget() {
    final lancamentos = [
      Transaction(
        id: 'L1',
        description: 'Salário',
        value: 5000.00,
        date: DateTime.now(),
        type: TransactionType.revenue,
        accountId: 'C1',
      ),
      Transaction(
        id: 'L2',
        description: 'Aluguel',
        value: 1200.00,
        date: DateTime.now(),
        type: TransactionType.expense,
        accountId: 'C1',
      ),
    ];

    // Filtrar por type
    final receitas = lancamentos
        .where((l) => l.type == TransactionType.revenue)
        .toList();

    final despesas = lancamentos
        .where((l) => l.type == TransactionType.expense)
        .toList();

    print('Receitas: ${receitas.length}');
    print('Despesas: ${despesas.length}');
  }

  void exemploExtension() {
    final type = TransactionType.revenue;

    print('Nome: ${type.displayName}');
    print('Cor: ${type.colorHex}');
    print('Símbolo: ${type.symbol}');

    final typeFromString = TransactionType.expense;
    print('Parse: $typeFromString');
  }

  void exemploLogica() {
    final lancamento = Transaction(
      id: 'L1',
      description: 'Venda',
      value: 1000,
      date: DateTime.now(),
      type: TransactionType.revenue,
      accountId: 'C1',
    );

    if (lancamento.type == TransactionType.revenue) {
      print('✅ Isso é uma receita');
    }

    switch (lancamento.type) {
      case TransactionType.revenue:
        print('Aumentar saldo');
        break;
      case TransactionType.expense:
        print('Diminuir saldo');
        break;
    }
  }
}
