import 'package:http/http.dart' as http;

import '../../application/contracts/cloud_sync_contracts.dart';
import '../../domain/entities/finance_entities.dart';

class OneDriveBackupService implements ICloudBackupService {
  final http.Client _httpClient;

  OneDriveBackupService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  @override
  CloudProvider get provider => CloudProvider.oneDrive;

  @override
  Future<void> uploadBackup({
    required UserSession session,
    required String payload,
  }) async {
    final token = session.oneDriveAccessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Token do OneDrive não encontrado para este usuário.');
    }

    final fileName =
        'my_finance_backup_${DateTime.now().toIso8601String()}.json';
    final encodedFileName = Uri.encodeComponent(fileName);
    final uri = Uri.parse(
      'https://graph.microsoft.com/v1.0/me/drive/root:/Apps/MyFinance/$encodedFileName:/content',
    );

    final response = await _httpClient.put(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: payload,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Falha ao salvar backup no OneDrive (${response.statusCode}).',
      );
    }
  }
}
