import 'dart:io';
import 'dart:async';
import 'dart:isolate';

void listDirIsolate(SendPort sendPort) {
  Directory pathing = Directory(r'h:\Backup Fedora\Projetos');
  final entities = pathing.listSync();
  sendPort.send(entities.length);
}

Future<void> viewDirParallel() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(listDirIsolate, receivePort.sendPort);
  final count = await receivePort.first;
  print('Total: $count itens');
}

void viewDir() {
  Directory pathing = Directory(r'h:\Backup Fedora\Projetos');
  final entities = pathing.listSync();
  for (var entity in entities) {
    print(entity.path);
  }
}

/// Cria um diretório no caminho especificado.
Future<void> createDirectory(String path) async {
  final directory = Directory(path);
  if (directory.existsSync()) {
    print('O diretório "$path" já existe.');
  } else {
    try {
      directory.createSync(recursive: true);
      print('Diretório "$path" criado com sucesso.');
    } catch (e) {
      print('Erro ao criar o diretório: $e');
    }
  }
}

/// Exclui um arquivo no caminho especificado.
Future<void> deleteFile(String path) async {
  final file = File(path);
  if (file.existsSync()) {
    try {
      file.deleteSync();
      print('Arquivo "$path" excluído com sucesso.');
    } catch (e) {
      print('Erro ao excluir o arquivo: $e');
    }
  } else {
    print('O arquivo "$path" não foi encontrado.');
  }
}

Future<T> measureExecution<T>(String name, Future<T> Function() action) async {
  final stopwatch = Stopwatch()..start();
  final result = await action();
  stopwatch.stop();
  print('Tempo de execução $name: ${stopwatch.elapsedMilliseconds} ms');
  return result;
}

Future<void> main(List<String> arguments) async {
  await measureExecution('viewDir', viewDirParallel);

  // if (arguments.isEmpty) {
  //   print('Uso:');
  //   print('  dart file_manager.dart create <{caminho_do_diretorio}>');
  //   print('  dart file_manager.dart delete <caminho_do_arquivo>');
  //   return;
  // }

  // final command = arguments[0];
  // if (arguments.length < 2) {
  //   print('Erro: Caminho não fornecido.');
  //   return;
  // }

  // final path = arguments[1];

  // switch (command) {
  //   case 'create':
  //     await measureExecution('createDirectory', () => createDirectory(path));
  //     break;
  //   case 'delete':
  //     await measureExecution('deleteFile', () => deleteFile(path));
  // }
}
