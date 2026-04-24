import 'package:googleapis_auth/googleapis_auth.dart';

Future<AutoRefreshingAuthClient> signInWithGoogleForDrive({
  required ClientId clientId,
  required List<String> scopes,
}) async {
  throw UnsupportedError(
    'Fluxo OAuth desktop não é usado nesta plataforma.',
  );
}
