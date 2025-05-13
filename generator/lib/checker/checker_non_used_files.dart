// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import '../utilities/directory_management.dart';
import '../utilities/printer_helper.dart';

final class CheckerNonUsedFiles extends PrinterHelper with DirectoryManagement {
  CheckerNonUsedFiles({
    required this.schemaFile,
    required this.resultFile,
    required this.searchDirectory,
  });

  final File schemaFile;
  final File resultFile;
  final Directory searchDirectory;

  Future<void> run() async {
    title("Arb Schema Json");
    print(
      "Reading schema json for obtain all keys"
          .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"),
    );
    final String all = await schemaFile.readAsString();
    final Map<String, dynamic> allJson = json.decode(all);
    final schemaKeys = allJson.keys.toSet()
      ..removeWhere((key) => key.contains('@'));

    _checkIfArbKeyExist(
      directoryToCheck: searchDirectory,
      schemaKeys: schemaKeys,
    );

    if (schemaKeys.isEmpty) {
      return print(
        "All key are used"
            .colorizeMessage(PrinterStringColor.green, emoji: "✅"),
      );
    }

    print(
      "Some keys was unused"
          .colorizeMessage(PrinterStringColor.red, emoji: "🚨"),
    );

    resultFile.writeAsStringSync(schemaKeys.toList().join('\n'));

    print(
      "File with duplicate key create"
          .colorizeMessage(PrinterStringColor.green, emoji: "✅"),
    );

    print(
      "Please review the file ${resultFile.path} "
          .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"),
    );
  }

  void _checkIfArbKeyExist({
    required Directory directoryToCheck,
    required Set<String> schemaKeys,
  }) {
    navigation(
      directory: directoryToCheck,
      navigationPrevent: (element) {
        return isArbFile(fileToCheck: element);
      },
      onDirectory: (newDirectory) => _checkIfArbKeyExist(
        directoryToCheck: newDirectory,
        schemaKeys: schemaKeys,
      ),
      onFile: (file) {
        String fileContent = file.readAsStringSync();
        final Set<String> fileArbKeyUsed = {};
        for (String arbKey in schemaKeys) {
          if (fileContent.contains(".$arbKey")) {
            fileArbKeyUsed.add(arbKey);
          }
        }

        for (String usedKey in fileArbKeyUsed) {
          schemaKeys.remove(usedKey);
        }
      },
    );
  }
}
