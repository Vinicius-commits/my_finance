import 'dart:async';

import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre o navegador para o consentimento Google e recebe o redirect em localhost.
Future<AutoRefreshingAuthClient> signInWithGoogleForDrive({
  required ClientId clientId,
  required List<String> scopes,
}) {
  return clientViaUserConsent(
    clientId,
    scopes,
    (String url) {
      unawaited(
        launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        ),
      );
    },
  );
}
