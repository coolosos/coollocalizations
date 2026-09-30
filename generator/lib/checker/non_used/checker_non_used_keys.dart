import 'dart:io';

import '../../utilities/directory_management.dart';
import '../../utilities/printer_helper.dart';
import '../extension/schema_key_extension.dart';

final class CheckerNonUsedKeys extends PrinterHelper with DirectoryManagement {
  new({
    required this.schemaFile,
    required this.resultFile,
    required this.searchDirectory,
  });

  final File schemaFile;
  final File resultFile;
  final Directory searchDirectory;

  Future<void> run() async {
    title('Arb Non Used Keys');
    print(
      'Reading schema json for obtain all keys'.colorizeMessage(
        PrinterStringColor.yellow,
        emoji: '🔛',
      ),
    );

    final schemaKeys = await schemaFile.getSchemaKeysFromProperties;

    _checkIfArbKeyExist(
      directoryToCheck: searchDirectory,
      schemaKeys: schemaKeys,
    );

    if (schemaKeys.isEmpty) {
      print(
        'All keys are used'.colorizeMessage(
          PrinterStringColor.green,
          emoji: '✅',
        ),
      );
      exit(0);
    }

    print(
      'Some keys are unused'.colorizeMessage(
        PrinterStringColor.red,
        emoji: '🚨',
      ),
    );

    await writeFileEnsuringDirectory(resultFile, schemaKeys.join('\n'));

    print(
      'File with unused keys created'.colorizeMessage(
        PrinterStringColor.green,
        emoji: '✅',
      ),
    );

    print(
      'Please review the file ${resultFile.path} '.colorizeMessage(
        PrinterStringColor.yellow,
        emoji: '🔛',
      ),
    );

    exit(1);
  }

  void _checkIfArbKeyExist({
    required Directory directoryToCheck,
    required Set<String> schemaKeys,
  }) {
    navigation(
      directory: directoryToCheck,
      navigationPrevent: (element) => isArbFile(fileToCheck: element),
      onDirectory: (newDirectory) => _checkIfArbKeyExist(
        directoryToCheck: newDirectory,
        schemaKeys: schemaKeys,
      ),
      onFile: (file) {
        final fileContent = file.readAsStringSync();
        final fileArbKeyUsed = schemaKeys
            .where((arbKey) => fileContent.contains('.$arbKey'))
            .toSet();
        schemaKeys.removeAll(fileArbKeyUsed);
      },
    );
  }
}
