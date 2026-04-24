import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';

/// Escopos usados no login Gmail e no upload para o Google Drive.
List<String> googleOAuthDriveScopes() => <String>[
  drive.DriveApi.driveFileScope,
  drive.DriveApi.driveAppdataScope,
  'https://www.googleapis.com/auth/userinfo.email',
  'https://www.googleapis.com/auth/userinfo.profile',
];

/// Cliente OAuth tipo **Desktop** do Google Cloud Console.
///
/// Compile com, por exemplo:
/// `flutter run --dart-define=GOOGLE_OAUTH_CLIENT_ID=SEU_ID.apps.googleusercontent.com`
///
/// Se o console gerar "Client secret", use:
/// `--dart-define=GOOGLE_OAUTH_CLIENT_SECRET=...`
ClientId? readGoogleOAuthDesktopClientId() {
  const id = String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID', defaultValue: '');
  if (id.isEmpty) {
    return null;
  }
  const secret = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_SECRET',
    defaultValue: '',
  );
  return ClientId(id, secret.isEmpty ? null : secret);
}
