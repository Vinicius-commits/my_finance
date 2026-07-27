import 'dart:convert';

import '../../domain/entities/finance_entities.dart';
import '../../domain/repositories/finance_repositories.dart';
import '../contracts/cloud_sync_contracts.dart';

class CloudBackupGateway {
  final Map<AuthProvider, ICloudBackupService> _backupByProvider;

  CloudBackupGateway({
    required ICloudBackupService googleDriveBackupService,
    required ICloudBackupService oneDriveBackupService,
  }) : _backupByProvider = {
         AuthProvider.gmail: googleDriveBackupService,
         AuthProvider.outlook: oneDriveBackupService,
       };

  Future<void> backup({
    required UserSession session,
    required String payload,
  }) async {
    final service = _backupByProvider[session.authProvider];
    if (service == null) {
      throw Exception('Nenhum serviço de backup configurado para este login.');
    }
    await service.uploadBackup(session: session, payload: payload);
  }
}

class BackupFinanceSnapshotUseCase {
  final ILancamentoRepository _transactionRepository;
  final IContaRepository _contaRepository;
  final CloudBackupGateway _cloudBackupGateway;

  BackupFinanceSnapshotUseCase({
    required ILancamentoRepository transactionRepository,
    required IContaRepository contaRepository,
    required CloudBackupGateway cloudBackupGateway,
  }) : _transactionRepository = transactionRepository,
       _contaRepository = contaRepository,
       _cloudBackupGateway = cloudBackupGateway;

  Future<void> call(UserSession session) async {
    final transactions = await _transactionRepository.getLancamentos();
    final contas = await _contaRepository.getContas();
    final payload = _buildPayload(
      session: session,
      transactions: transactions,
      contas: contas,
    );
    await _cloudBackupGateway.backup(session: session, payload: payload);
  }

  String _buildPayload({
    required UserSession session,
    required List<Transaction> transactions,
    required List<Conta> contas,
  }) {
    final map = <String, dynamic>{
      'generatedAt': DateTime.now().toIso8601String(),
      'user': {
        'id': session.userId,
        'name': session.displayName,
        'email': session.email,
        'provider': session.authProvider.name,
      },
      'accounts': contas
          .map(
            (conta) => {
              'id': conta.id,
              'name': conta.name,
              'balance': conta.currency,
            },
          )
          .toList(),
      'transactions': transactions
          .map(
            (transaction) => {
              'id': transaction.id,
              'description': transaction.description,
              'value': transaction.value,
              'type': transaction.type.name,
              'accountId': transaction.accountId,
              'date': transaction.date.toIso8601String(),
              if (transaction.categoryId != null)
                'categoryId': transaction.categoryId,
            },
          )
          .toList(),
    };
    return jsonEncode(map);
  }
}
