import '../../domain/repositories/finance_repositories.dart';
import '../../domain/entities/finance_entities.dart';

// Casos de uso para Lançamentos
class AddLancamentoUseCase {
  final ILancamentoRepository repository;

  AddLancamentoUseCase(this.repository);

  Future<void> call(Transaction lancamento) async {
    await repository.saveLancamento(lancamento);
  }
}

class GetLancamentosUseCase {
  final ILancamentoRepository repository;

  GetLancamentosUseCase(this.repository);

  Future<List<Transaction>> call() async {
    return await repository.getLancamentos();
  }
}

class DeleteLancamentoUseCase {
  final ILancamentoRepository repository;

  DeleteLancamentoUseCase(this.repository);

  Future<void> call(String id) => repository.deleteLancamento(id);
}

// Casos de uso para Contas
class GetContasUseCase {
  final IContaRepository repository;

  GetContasUseCase(this.repository);

  Future<List<Conta>> call() async {
    return await repository.getContas();
  }
}

class AddContaUseCase {
  final IContaRepository repository;

  AddContaUseCase(this.repository);

  Future<void> call(Conta conta) async {
    await repository.saveConta(conta);
  }
}

// Casos de uso para Metas
class GetMetasUseCase {
  final IMetaRepository repository;

  GetMetasUseCase(this.repository);

  Future<List<Meta>> call() async {
    return await repository.getMetas();
  }
}

class GetCategoriasUseCase {
  final ICategoriaRepository repository;

  GetCategoriasUseCase(this.repository);

  Future<List<MovementCategory>> call() => repository.getCategorias();
}

class SaveCategoriaUseCase {
  final ICategoriaRepository repository;

  SaveCategoriaUseCase(this.repository);

  Future<void> call(MovementCategory categoria) =>
      repository.saveCategoria(categoria);
}

class DeleteCategoriaUseCase {
  final ICategoriaRepository repository;

  DeleteCategoriaUseCase(this.repository);

  Future<void> call(String id) => repository.deleteCategoria(id);
}
