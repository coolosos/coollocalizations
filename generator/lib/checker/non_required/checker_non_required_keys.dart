import 'dart:convert';
import 'dart:io';

import '../../utilities/directory_management.dart';
import '../../utilities/printer_helper.dart';
import '../extension/language_implementation_extension.dart';
import '../extension/schema_key_extension.dart';

final class CheckerNonRequiredKeys extends PrinterHelper
    with DirectoryManagement {
  new({
    required this.schemaFile,
    required this.resultFile,
    required this.searchFile,
  });

  final File schemaFile;
  final File resultFile;
  final File searchFile;

  Future<void> run() async {
    title('Arb Check Non Required Keys');
    print(
      'Reading schema json for obtain all keys'.colorizeMessage(
        PrinterStringColor.yellow,
        emoji: '🔛',
      ),
    );

    final schemaKeys = await schemaFile.getSchemaKeysFromProperties;

    final languages = await searchFile.getLanguages;

    final nonNecessaryKeys = _obtainNonNecessary(languages, schemaKeys);

    if (nonNecessaryKeys.isEmpty) {
      print(
        'All keys are necessary'.colorizeMessage(
          PrinterStringColor.green,
          emoji: '✅',
        ),
      );

      exit(0);
    }

    print(
      'Some keys are not necessary'.colorizeMessage(
        PrinterStringColor.red,
        emoji: '🚨',
      ),
    );

    final report = <String, dynamic>{
      'result': nonNecessaryKeys.entries
          .map(
            (entry) => <String, dynamic>{
              'locale': entry.key,
              'non_requires': entry.value,
            },
          )
          .toList(),
    };
    await writeFileEnsuringDirectory(
      resultFile,
      const JsonEncoder.withIndent('  ').convert(report),
    );

    print(
      'File with non necessary keys by language was created'.colorizeMessage(
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

  Map<String, List<String>> _obtainNonNecessary(
    List<Map<String, dynamic>> languages,
    Set<String> schemaKeys,
  ) {
    final nonNecessaryObjects = <String, List<String>>{};
    for (final language in languages) {
      final allKeys = language.keys.toSet()..remove('locale');
      final nonNecessaryKeys = allKeys
          .where((key) => !schemaKeys.contains(key))
          .toList();
      final locale = language['locale'];
      if (nonNecessaryKeys.isNotEmpty && locale is String) {
        nonNecessaryObjects[locale] = nonNecessaryKeys;
      }
    }
    return nonNecessaryObjects;
  }
}
