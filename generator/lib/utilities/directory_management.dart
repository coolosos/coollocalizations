import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'extension.dart';

mixin DirectoryManagement {
  void navigation({
    required Directory directory,
    required Function(Directory newDirectory) onDirectory,
    required Function(File file) onFile,
    bool Function(FileSystemEntity element)? navigationPrevent,
  }) {
    for (FileSystemEntity element in directory.listSync()) {
      if (navigationPrevent != null) {
        if (navigationPrevent.call(element)) {
          continue;
        }
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
    required Map<dynamic, dynamic> formattedArb,
  }) {
    final filePath = primeFile.path;
    String arbGenerated = path.absolute(primeFile.path);
    if (!filePath.contains('.g.arb')) {
      arbGenerated = arbGenerated.replaceAll('.arb', '.g.arb');
    }

    final File outputFile = File(arbGenerated);
    var encoder = const JsonEncoder.withIndent(null);

    print(
      'Writting file'.colorizeMessage(PrinterStringColor.cyan, emoji: '🚀'),
    );
    outputFile.writeAsStringSync(encoder.convert(formattedArb));

    print(
      'Writting success'.colorizeMessage(PrinterStringColor.green, emoji: '✅'),
    );
    print('----------------------------------------');
    return outputFile;
  }

  bool isArbFile({required FileSystemEntity fileToCheck}) {
    return path.extension(fileToCheck.path).contains('arb');
  }
}
