import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/finance_entities.dart';
import '../../application/usecases/finance_usecases.dart';

// Estados para Lançamentos
abstract class LancamentoState {}

class LancamentoInitial extends LancamentoState {}

class LancamentoLoading extends LancamentoState {}

class LancamentoLoaded extends LancamentoState {
  final List<Transaction> lancamentos;
  LancamentoLoaded(this.lancamentos);
}

class LancamentoError extends LancamentoState {
  final String message; // sempre inclua mensagem nos estados de erro
  LancamentoError(this.message);
}

// ─── CUBIT: LANÇAMENTOS ───────────────────────────────────────────────────────

class LancamentoCubit extends Cubit<LancamentoState> {
  final GetLancamentosUseCase _getLancamentos;
  final AddLancamentoUseCase _addLancamento;

  LancamentoCubit({
    required GetLancamentosUseCase getLancamentos,
    required AddLancamentoUseCase addLancamento,
  }) : _getLancamentos = getLancamentos,
       _addLancamento = addLancamento,
       super(LancamentoInitial());

  // Carrega todos os lançamentos do banco
  Future<void> loadLancamentos() async {
    emit(LancamentoLoading());
    try {
      final lista = await _getLancamentos(); // chama o UseCase
      emit(LancamentoLoaded(lista));
    } catch (e) {
      emit(LancamentoError('Erro ao carregar lançamentos'));
    }
  }

  // Salva um lançamento e recarrega a lista
  Future<void> addLancamento(Transaction lancamento) async {
    try {
      await _addLancamento(lancamento); // chama o UseCase
      await loadLancamentos(); // atualiza a tela automaticamente
    } catch (e) {
      emit(LancamentoError('Erro ao salvar lançamento'));
    }
  }
}

// ─── ESTADOS: CONTAS ──────────────────────────────────────────────────────────

abstract class ContaState {}

class ContaInitial extends ContaState {}

class ContaLoading extends ContaState {}

class ContaLoaded extends ContaState {
  final List<Conta> contas;
  ContaLoaded(this.contas);
}

class ContaError extends ContaState {
  final String message;
  ContaError(this.message);
}

// ─── CUBIT: CONTAS ────────────────────────────────────────────────────────────

class ContaCubit extends Cubit<ContaState> {
  final GetContasUseCase _getContas;
  final AddContaUseCase _addConta;

  ContaCubit({
    required GetContasUseCase getContas,
    required AddContaUseCase addConta,
  })
    : _getContas = getContas,
      _addConta = addConta,
      super(ContaInitial());

  Future<void> loadContas() async {
    emit(ContaLoading());
    try {
      final lista = await _getContas();
      emit(ContaLoaded(lista));
    } catch (e) {
      emit(ContaError('Erro ao carregar contas'));
    }
  }

  Future<void> addConta(Conta conta) async {
    try {
      await _addConta(conta);
      await loadContas();
    } catch (e) {
      emit(ContaError('Erro ao salvar conta'));
    }
  }
}
