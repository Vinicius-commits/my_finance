import '../../domain/repositories/finance_repositories.dart';
import '../../domain/entities/finance_entities.dart';
import '../datasources/finance_datasource.dart';
import '../models/finance_models.dart';

// Implementações dos repositórios com Sqflite
class ContaRepositoryImpl implements IContaRepository {
  final IFinanceDatasource datasource;

  ContaRepositoryImpl(this.datasource);

  @override
  Future<List<Conta>> getContas() async {
    final models = await datasource.getContaModels();
    return models
        .map(
          (model) =>
              Conta(id: model.id, name: model.name, currency: model.currency),
        )
        .toList();
  }

  @override
  Future<void> saveConta(Conta conta) async {
    final model = ContaModel(
      id: conta.id,
      name: conta.name,
      currency: conta.currency,
    );
    await datasource.saveContaModel(model);
  }

  @override
  Future<void> deleteConta(String id) async {
    await datasource.deleteContaModel(id);
  }
}

class TransactionRepositoryImpl implements ILancamentoRepository {
  final IFinanceDatasource datasource;

  TransactionRepositoryImpl(this.datasource);

  @override
  Future<List<Transaction>> getLancamentos() async {
    final models = await datasource.getLancamentoModels();
    return models
        .map(
          (model) => Transaction(
            id: model.id,
            description: model.description,
            value: model.value,
            date: model.date,
            type: model.type,
            accountId: model.accountId,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveLancamento(Transaction lancamento) async {
    final model = TransactionModel(
      id: lancamento.id,
      description: lancamento.description,
      value: lancamento.value,
      date: lancamento.date,
      type: lancamento.type,
      accountId: lancamento.accountId,
    );
    await datasource.saveLancamentoModel(model);
  }

  @override
  Future<void> deleteLancamento(String id) async {
    await datasource.deleteLancamentoModel(id);
  }
}

class MetaRepositoryImpl implements IMetaRepository {
  final IFinanceDatasource datasource;

  MetaRepositoryImpl(this.datasource);

  @override
  Future<List<Meta>> getMetas() async {
    final models = await datasource.getMetaModels();
    return models
        .map(
          (model) => Meta(
            id: model.id,
            name: model.titulo,
            targetvalue: model.valorAlvo,
            currentValue: model.valorAtual,
            deadline: model.dataLimite,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveMeta(Meta meta) async {
    final model = MetaModel(
      id: meta.id,
      titulo: meta.name,
      valorAlvo: meta.targetvalue,
      valorAtual: meta.currentValue,
      dataLimite: meta.deadline,
    );
    await datasource.saveMetaModel(model);
  }

  @override
  Future<void> deleteMeta(String id) async {
    await datasource.deleteMetaModel(id);
  }
}
