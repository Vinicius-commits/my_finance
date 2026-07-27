import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferência e autenticação local para bloquear o app (biometria / credenciais do aparelho).
class BiometricLockService {
  BiometricLockService() : _auth = LocalAuthentication();

  static const _prefsKey = 'app_biometric_lock_enabled';

  final LocalAuthentication _auth;

  /// Há suporte a prompt de credencial do sistema (biometria, PIN, padrão, etc.).
  Future<bool> isDeviceCredentialAuthSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> isLockEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_prefsKey) ?? false;
  }

  Future<void> setLockEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_prefsKey, value);
  }

  /// Aparelho com leitor de biometria cadastrada (impressão digital, rosto, etc.).
  Future<bool> hasEnrolledBiometrics() async {
    if (!await _auth.isDeviceSupported()) {
      return false;
    }
    final types = await _auth.getAvailableBiometrics();
    return types.isNotEmpty;
  }

  /// Desbloqueia o app. [biometricOnly] exige biometria (sem PIN como substituto no prompt).
  Future<bool> unlock({
    String reason = 'Desbloqueie o app para continuar',
    bool biometricOnly = true,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
