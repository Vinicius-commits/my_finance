import '../../domain/entities/finance_entities.dart';

abstract class ICloudBackupService {
  CloudProvider get provider;

  Future<void> uploadBackup({
    required UserSession session,
    required String payload,
  });
}
