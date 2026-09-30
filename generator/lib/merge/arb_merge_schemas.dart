import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';

import '../utilities/directory_management.dart';
import '../utilities/json_decoder.dart';
import '../utilities/printer_helper.dart';

enum TypologyMerge {
  any,
  localization;

  static TypologyMerge fromString(String? typology) {
    return TypologyMerge.values.firstWhereOrNull(
          (element) => element.name.toLowerCase() == typology?.toLowerCase(),
        ) ??
        any;
  }
}

final class ArbMergeSchemas with PrinterHelper, DirectoryManagement {
  const new({
    required this.allLocalizations,
    required this.mergeLocalizations,
    required this.outputFile,
    required this.typology,
    this.additionalReplacements = const <String, String>{},
  });

  final File allLocalizations;
  final File mergeLocalizations;

  final File outputFile;

  final TypologyMerge typology;

  /// Reemplazos globales adicionales, con el formato `palabra:reemplazo`.
  final Map<String, String> additionalReplacements;

  Future<void> run() async {
    title('Merge Json');
    print(
      'Reading common json'.colorizeMessage(
        PrinterStringColor.yellow,
        emoji: '🔛',
      ),
    );
    final all = await allLocalizations.readAsString();
    final allJson = decodeJsonMap(all, context: 'all localizations file');
    print(
      'Reading merge json'.colorizeMessage(
        PrinterStringColor.yellow,
        emoji: '🔛',
      ),
    );
    final merge = await mergeLocalizations.readAsString();
    final mergeJson = decodeJsonMap(merge, context: 'merge localizations file');
    print(
      'Reading replacements in merge json'.colorizeMessage(
        PrinterStringColor.yellow,
        emoji: '🔛',
      ),
    );
    final replacements = _obtainReplacement(mergeJson);

    final checkSchema = mergeJson['checkSchema'];
    if (checkSchema is String) {
      allJson[r'$schema'] = checkSchema;
    }
    final fromLocalization = obtainLocalizations(mergeJson, allJson);

    if (fromLocalization case final fromLocalization?) {
      final value = List<Map<String, dynamic>>.from(
        fromLocalization.commonLocalization,
      );
      _replaceByLocalizationListSchema(
        value,
        fromLocalization.replacementLocalization,
        replacementWithLocale: replacements.localeReplacement,
      );
      allJson['localizations'] = value;
    } else {
      _replaceByMatchKeys(mergeJson, allJson);
    }

    const encoder = JsonEncoder.withIndent('  ');

    var fileAsString = encoder.convert(allJson);

    for (final entry in additionalReplacements.entries) {
      fileAsString = fileAsString.replaceAll(entry.key, entry.value);
    }

    if (replacements.replacement case final globalReplacements
        when globalReplacements.isNotEmpty) {
      for (final map in globalReplacements) {
        final word = map['word'];
        final replacement = map['replacement'];
        if (word is String && replacement is String) {
          fileAsString = fileAsString.replaceAll(word, replacement);
        }
      }
    }

    await writeFileEnsuringDirectory(outputFile, fileAsString);
    print(
      'Creation file success'.colorizeMessage(
        PrinterStringColor.green,
        emoji: '✨',
      ),
    );
  }

  ({
    List<Map<String, dynamic>> localeReplacement,
    List<Map<String, dynamic>> replacement,
  })
  _obtainReplacement(Map<String, dynamic> mergeJson) {
    final dynamicReplacements = mergeJson['replacement'];
    final replacements = dynamicReplacements is List<Object?>
        ? dynamicReplacements.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    final groupByLocalesAndNoLocales = replacements.groupListsBy(
      (element) => element['locales'] is List<Object?>,
    );

    return (
      localeReplacement:
          groupByLocalesAndNoLocales[true] ?? const <Map<String, dynamic>>[],
      replacement:
          groupByLocalesAndNoLocales[false] ?? const <Map<String, dynamic>>[],
    );
  }

  ({
    List<Map<String, dynamic>> commonLocalization,
    List<Map<String, dynamic>> replacementLocalization,
  })?
  obtainLocalizations(
    Map<String, dynamic> mergeJson,
    Map<String, dynamic> allJson,
  ) {
    try {
      final allLocalizations = asJsonList(
        allJson['localizations'],
        context: 'all localizations',
      ).whereType<Map<String, dynamic>>().toList();
      final mergeLocalizations = asJsonList(
        mergeJson['localizations'],
        context: 'merge localizations',
      ).whereType<Map<String, dynamic>>().toList();

      final locale = allLocalizations.any(
        (element) => element['locale'] == null,
      );

      if (locale) {
        final otherContainsLocale = allLocalizations.any(
          (element) => element['locale'] != null,
        );

        if (otherContainsLocale) {
          print(
            'Warning: Maybe you have localizations without locale key, this break the json schema arb_localization for localization. If your merge if not from localization you can ignore this warning'
                .colorizeMessage(PrinterStringColor.yellow, emoji: '🚨'),
          );
        }
        throw UnsupportedError(
          'It cannot be localization because there have not locale',
        );
      }

      return (
        commonLocalization: allLocalizations,
        replacementLocalization: mergeLocalizations,
      );
    } catch (e) {
      if (typology == TypologyMerge.localization) {
        rethrow;
      }
      return null;
    }
  }

  void _replaceByMatchKeys(
    Map<String, dynamic> mergeJson,
    Map<String, dynamic> allJson,
  ) {
    print(
      'Proceeded to change match keys'.colorizeMessage(
        PrinterStringColor.magenta,
        emoji: '🔛',
      ),
    );
    for (final merges in mergeJson.entries) {
      allJson.update(
        merges.key,
        (value) => merges.value,
        ifAbsent: () {
          return merges.value;
        },
      );
    }
  }

  List<Map<String, dynamic>> _replaceByLocalizationListSchema(
    List<Map<String, dynamic>> allLocalizations,
    List<Map<String, dynamic>> mergeLocalizations, {
    required List<Map<String, dynamic>> replacementWithLocale,
  }) {
    print(
      'Localizations find, proceeded to change internal localizations'
          .colorizeMessage(PrinterStringColor.magenta, emoji: '🔛'),
    );

    for (final mergeInternal in mergeLocalizations) {
      final internalLocale = mergeInternal['locale'];

      final internalLocalizationWithAllLocalizations = allLocalizations
          .firstWhereOrNull((element) => element['locale'] == internalLocale);

      if (internalLocalizationWithAllLocalizations != null) {
        //In all localizations exist the merge language
        _deleteAndUpdateInternalLocalization(
          allLocalizations,
          internalLocalizationWithAllLocalizations,
          mergeInternal,
        );
        allLocalizations.add(internalLocalizationWithAllLocalizations);
      }
    }

    _replaceAllLocalizationWordsByLocale(
      replacementWithLocale,
      allLocalizations,
    );

    return allLocalizations;
  }

  ///Iterate all the locales localization and try to replace the words if its possible
  void _replaceAllLocalizationWordsByLocale(
    List<Map<String, dynamic>> replacementWithLocale,
    List<Map<String, dynamic>> allLocalizations,
  ) {
    if (replacementWithLocale.isEmpty) {
      return;
    }

    final allLocaleWIthOutReplacements = List<Map<String, dynamic>>.from(
      allLocalizations,
    );
    allLocalizations.clear();

    for (final localizationByLocale in allLocaleWIthOutReplacements) {
      final internalLocale = asJsonString(
        localizationByLocale['locale'],
        context: 'locale of $localizationByLocale',
      );

      final replacementOfInternalLocale = replacementWithLocale.where((
        element,
      ) {
        final locales = element['locales'];
        if (locales is List<Object?>) {
          return locales.contains(internalLocale) &&
              element['word'] is String &&
              element['replacement'] is String;
        }
        return false;
      }).toList();

      if (replacementOfInternalLocale.isEmpty) {
        allLocalizations.add(localizationByLocale);
        continue;
      }

      var mapToStringConverter = json.encode(localizationByLocale);
      for (final replacement in replacementOfInternalLocale) {
        final word = asJsonString(
          replacement['word'],
          context: 'word of $replacement',
        );
        final replacementWord = asJsonString(
          replacement['replacement'],
          context: 'replacement of $replacement',
        );
        mapToStringConverter = mapToStringConverter.replaceAll(
          word,
          replacementWord,
        );
      }

      allLocalizations.add(
        decodeJsonMap(
          mapToStringConverter,
          context: 'replaced $internalLocale',
        ),
      );
    }
  }

  ///Delete localization for father localizations and added again with the merge updates
  void _deleteAndUpdateInternalLocalization(
    List<Map<String, dynamic>> allLocalizations,
    Map<String, dynamic> internalLocalizationWithAllLocalizations,
    Map<String, dynamic> mergeInternal,
  ) {
    allLocalizations.removeWhere(
      (element) => element == internalLocalizationWithAllLocalizations,
    );
    for (final merges in mergeInternal.entries) {
      internalLocalizationWithAllLocalizations.update(
        merges.key,
        (value) {
          print(
            'Update {${merges.key}:${merges.value}.}'.colorizeMessage(
              PrinterStringColor.green,
              emoji: '✅',
            ),
          );
          final complexValues = merges.value;
          if (complexValues is Map<String, dynamic>) {
            final entryToOverride = internalLocalizationWithAllLocalizations
                .entries
                .firstWhere((element) => element.key == merges.key);
            final valueToOverride = asJsonMap(
              entryToOverride.value,
              context: 'value of ${merges.key}',
            );
            for (final internalValues in complexValues.entries) {
              valueToOverride.update(
                internalValues.key,
                (value) => internalValues.value,
                ifAbsent: () {
                  print(
                    r"Added ${merges.key} with value ${merges.value}. This key doesn't exist in the previous json"
                        .colorizeMessage(PrinterStringColor.red, emoji: '🚨'),
                  );

                  return internalValues.value;
                },
              );
            }
            return valueToOverride;
          }

          return merges.value;
        },
        ifAbsent: () {
          print(
            r"Added ${merges.key} with value ${merges.value}. This key doesn't exist in the previous json"
                .colorizeMessage(PrinterStringColor.red, emoji: '🚨'),
          );

          return merges.value;
        },
      );
    }
  }
}
