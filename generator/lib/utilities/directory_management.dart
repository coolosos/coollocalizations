import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'extension.dart';

mixin DirectoryManagement {
  void navigation({
    required Directory directory,
    required void Function(Directory) onDirectory,
    required void Function(File) onFile,
    bool Function(FileSystemEntity)? navigationPrevent,
  }) {
    for (final element in directory.listSync()) {
      if (navigationPrevent != null && navigationPrevent.call(element)) {
        continue;
      }
      if (element is Directory) {
        onDirectory.call(element);
      } else if (element is File) {
        onFile.call(element);
      }
    }
  }

  File saveGenerateFile({
    required File primeFile,
    required Map<String, dynamic> formattedArb,
  }) {
    final filePath = primeFile.path;
    var arbGenerated = p.absolute(primeFile.path);
    if (!filePath.contains('.g.arb')) {
      arbGenerated = arbGenerated.replaceAll('.arb', '.g.arb');
    }

    final outputFile = File(arbGenerated);
    const encoder = JsonEncoder.withIndent(null);

    print(
      'Writting file'.colorizeMessage(PrinterStringColor.cyan, emoji: '🚀'),
    );
    createParentDirectorySync(outputFile);
    outputFile.writeAsStringSync(encoder.convert(formattedArb));

    print(
      'Writting success'.colorizeMessage(PrinterStringColor.green, emoji: '✅'),
    );
    print('----------------------------------------');
    return outputFile;
  }

  bool isArbFile({required FileSystemEntity fileToCheck}) {
    return p.extension(fileToCheck.path).contains('arb');
  }
}

/// Crea el directorio padre de [file] si no existe.
Future<Directory> createParentDirectory(File file) async {
  final parent = Directory(p.dirname(p.absolute(file.path)));
  if (!await parent.exists()) {
    await parent.create(recursive: true);
  }
  return parent;
}

/// Igual que [createParentDirectory] pero de forma sincrona.
void createParentDirectorySync(File file) {
  final parent = Directory(p.dirname(p.absolute(file.path)));
  if (!parent.existsSync()) {
    parent.createSync(recursive: true);
  }
}

/// Escribe [content] en [file] creando su directorio padre si hace falta.
Future<File> writeFileEnsuringDirectory(File file, String content) async {
  await createParentDirectory(file);
  await file.writeAsString(content);
  return file;
}
