import 'dart:io';
import 'dart:convert';

Future<int> runBat(String batPath, List<String> args) async {
  final result = await Process.run(
    'powershell.exe',
    ['-ExecutionPolicy', 'Bypass', '-File', batPath] + args,
    workingDirectory: Directory.current.path,
    runInShell: false,
    includeParentEnvironment: true,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );

  stdout.write(result.stdout);
  stderr.write(result.stderr);
  return result.exitCode;
}

Future<int> runBatStream(String batPath, List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final process = await Process.start(batPath, args, runInShell: true);

  process.stdout.transform(utf8.decoder).listen(stdout.write);
  process.stderr.transform(utf8.decoder).listen(stderr.write);

  final exitCode = await process.exitCode;
  stopwatch.stop();
  print('bat executado em ${stopwatch.elapsedMilliseconds} ms');
  return exitCode;
}

void main() async {
  final bat =
      r'h:\Backup Fedora\Projetos\Producoes Particulares\Projetos de aplicativos\Backup-Flutter\Finance\my_finance\lib\check_CPU.ps1';
  final t0 = DateTime.now();
  final code = await runBat(bat, ['arg1', 'arg2']);
  final t1 = DateTime.now();
  print('exitCode=$code tempo=${t1.difference(t0).inMilliseconds}ms');
}
