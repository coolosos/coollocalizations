// ignore_for_file: avoid_print

import 'dart:io';

import '../../utilities/directory_management.dart';
import '../../utilities/printer_helper.dart';
import '../extension/language_implementation_extension.dart';
import '../extension/schema_key_extension.dart';

final class CheckerNonRequiredKeys extends PrinterHelper
    with DirectoryManagement {
  CheckerNonRequiredKeys({
    required this.schemaFile,
    required this.resultFile,
    required this.searchFile,
  });

  final File schemaFile;
  final File resultFile;
  final File searchFile;

  Future<void> run() async {
    title("Arb Check Non Required Keys");
    print(
      "Reading schema json for obtain all keys"
          .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"),
    );

    final schemaKeys = await schemaFile.getSchemaKeysFromProperties;

    final List<Map<String, dynamic>> languages = await searchFile.getLanguages;

    final Map<String, List<String>> nonNecessaryKeys =
        _obtainNonNecessary(languages, schemaKeys);

    if (nonNecessaryKeys.isEmpty) {
      return print(
        "All key are necessary"
            .colorizeMessage(PrinterStringColor.green, emoji: "✅"),
      );
    }

    print(
      "Some keys was not necessary"
          .colorizeMessage(PrinterStringColor.red, emoji: "🚨"),
    );

    resultFile.writeAsStringSync('{"result":[${nonNecessaryKeys.entries.map(
      (e) => '{"locale":{${e.key}}, "non_requires":[${e.value.join('\n')}]}',
    )}]}');

    print(
      "File with non necessary keys by language was create"
          .colorizeMessage(PrinterStringColor.green, emoji: "✅"),
    );

    print(
      "Please review the file ${resultFile.path} "
          .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"),
    );
  }

  Map<String, List<String>> _obtainNonNecessary(
    List<Map<String, dynamic>> languages,
    Set<String> schemaKeys,
  ) {
    final Map<String, List<String>> nonNecessaryObjects = {};
    for (var i = 0; i < languages.length; i++) {
      final language = languages[i];
      final locale = language.remove('locale');
      final allKeys = language.keys;
      final List<String> nonNecessaryKeys = [];
      for (String key in allKeys) {
        print("${schemaKeys.join()}\n$key");
        if (!schemaKeys.contains(key)) {
          nonNecessaryKeys.add(key);
        }
      }
      if (nonNecessaryKeys.isNotEmpty) {
        nonNecessaryObjects.addAll({locale: nonNecessaryKeys});
      }
    }
    return nonNecessaryObjects;
  }
}
