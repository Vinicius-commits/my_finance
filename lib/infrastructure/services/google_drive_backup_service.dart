import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';

import '../../application/contracts/cloud_sync_contracts.dart';
import '../../domain/entities/finance_entities.dart';
import 'google_auth_session.dart';

class GoogleDriveBackupService implements ICloudBackupService {
  GoogleDriveBackupService(this._googleSignIn, this._googleAuthSession);

  final GoogleSignIn _googleSignIn;
  final GoogleAuthSession _googleAuthSession;

  bool _isWindowsOrLinuxDesktop() {
    if (kIsWeb) {
      return false;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  @override
  CloudProvider get provider => CloudProvider.googleDrive;

  @override
  Future<void> uploadBackup({
    required UserSession session,
    required String payload,
  }) async {
    final desktop = _googleAuthSession.desktopClient;
    if (desktop != null) {
      await _uploadWithClient(desktop, payload);
      return;
    }

    if (_isWindowsOrLinuxDesktop()) {
      throw Exception(
        'Sessão Google Drive não encontrada. Saia e entre novamente com Gmail.',
      );
    }

    final account =
        await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
    if (account == null) {
      throw Exception(
        'Sessão Google não encontrada. Faça login com Gmail novamente.',
      );
    }

    final authClient = await _googleSignIn.authenticatedClient();
    if (authClient == null) {
      throw Exception('Não foi possível autenticar no Google Drive.');
    }

    try {
      await _uploadWithClient(authClient, payload);
    } finally {
      authClient.close();
    }
  }

  Future<void> _uploadWithClient(AuthClient authClient, String payload) async {
    final driveApi = drive.DriveApi(authClient);
    final bytes = utf8.encode(payload);
    final fileName =
        'my_finance_backup_${DateTime.now().toIso8601String()}.json';

    final file = drive.File()
      ..name = fileName
      ..mimeType = 'application/json'
      ..parents = <String>['appDataFolder'];

    await driveApi.files.create(
      file,
      uploadMedia: drive.Media(Stream.value(bytes), bytes.length),
    );
  }
}
