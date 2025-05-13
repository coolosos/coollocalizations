// ignore_for_file: avoid_print

import 'dart:io';

import '../../utilities/directory_management.dart';
import '../../utilities/printer_helper.dart';
import '../extension/schema_key_extension.dart';

final class CheckerNonUsedKeys extends PrinterHelper with DirectoryManagement {
  CheckerNonUsedKeys({
    required this.schemaFile,
    required this.resultFile,
    required this.searchDirectory,
  });

  final File schemaFile;
  final File resultFile;
  final Directory searchDirectory;

  Future<void> run() async {
    title("Arb Non Used Keys");
    print(
      "Reading schema json for obtain all keys"
          .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"),
    );

    final schemaKeys = await schemaFile.getSchemaKeysFromProperties;

    _checkIfArbKeyExist(
      directoryToCheck: searchDirectory,
      schemaKeys: schemaKeys,
    );

    if (schemaKeys.isEmpty) {
      print(
        "All key are used"
            .colorizeMessage(PrinterStringColor.green, emoji: "✅"),
      );
      exit(0);
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

    exit(1);
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
