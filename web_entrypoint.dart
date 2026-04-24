// Ponto de entrada opcional para compilar/rodar o app na Web.
//
// Uso:
//   flutter run -d chrome -t web_entrypoint.dart
//   flutter build web -t web_entrypoint.dart
//
// Chama a mesma inicialização de [lib/main.dart], com URL em modo path
// (sem "#/" no endereço), útil se você passar a usar rotas nomeadas.
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'lib/main.dart' as app;

void main() {
  usePathUrlStrategy();
  app.main();
}
