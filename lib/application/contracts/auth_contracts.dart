import '../../domain/entities/finance_entities.dart';

abstract class IAuthService {
  Future<UserSession> loginWithGmail();

  Future<UserSession> loginWithDeviceUnlock();

  Future<UserSession> loginWithOutlook({
    required String email,
    required String oneDriveAccessToken,
  });

  Future<void> logout();
}
