import '../entities/finance_entities.dart';

// Interfaces dos repositórios
abstract class IContaRepository {
  Future<List<Conta>> getContas();
  Future<void> saveConta(Conta conta);
  Future<void> deleteConta(String id);
}

abstract class ILancamentoRepository {
  Future<List<Transaction>> getLancamentos();
  Future<void> saveLancamento(Transaction lancamento);
  Future<void> deleteLancamento(String id);
}

abstract class ICategoriaRepository {
  Future<List<MovementCategory>> getCategorias();
  Future<void> saveCategoria(MovementCategory categoria);
  Future<void> deleteCategoria(String id);
}

abstract class IMetaRepository {
  Future<List<Meta>> getMetas();
  Future<void> saveMeta(Meta meta);
  Future<void> deleteMeta(String id);
}
