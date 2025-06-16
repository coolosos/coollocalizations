import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';

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

final class ArbMergeSchemas with PrinterHelper {
  const ArbMergeSchemas({
    required this.allLocalizations,
    required this.mergeLocalizations,
    required this.outputFile,
    required this.typology,
  });

  final File allLocalizations;
  final File mergeLocalizations;

  final File outputFile;

  final TypologyMerge typology;

  Future<void> run() async {
    title("Merge Json");
    print(
      "Reading common json"
          .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"),
    );
    final String all = await allLocalizations.readAsString();
    final Map<String, dynamic> allJson = json.decode(all);
    print(
      "Reading merge json"
          .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"),
    );
    final merge = await mergeLocalizations.readAsString();
    final Map<String, dynamic> mergeJson = json.decode(merge);
    print(
      "Reading replacements in merge json"
          .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"),
    );
    final replacements = _obtainReplacement(mergeJson);

    print(
      "Print replacements in merge json: \n$replacements"
          .colorizeMessage(PrinterStringColor.magenta, emoji: "🧱"),
    );

    if (mergeJson['checkSchema'] != null) {
      allJson['\$schema'] = mergeJson['checkSchema'];
    }

    final fromLocalization = obtainLocalizations(mergeJson, allJson);

    if (fromLocalization case final fromLocalization?) {
      _replaceByLocalizationListSchema(
        fromLocalization.commonLocalization,
        fromLocalization.replacementLocalization,
        replacementWithLocale: replacements.localeReplacement,
      );
    } else {
      _replaceByMatchKeys(mergeJson, allJson);
    }

    var encoder = const JsonEncoder.withIndent("  ");

    String fileAsString = encoder.convert(allJson);

    if (replacements.replacement case final replacements
        when replacements.isNotEmpty) {
      for (var map in replacements) {
        final word = map['word'];
        final replacement = map['replacement'];
        if (word is String && replacement is String) {
          fileAsString = fileAsString.replaceAll(word, replacement);
        }
      }
    }

    outputFile.writeAsStringSync(fileAsString);
    print(
      "Creation file success"
          .colorizeMessage(PrinterStringColor.green, emoji: "✨"),
    );
  }

  ({
    List<Map<String, dynamic>> localeReplacement,
    List<Map<String, dynamic>> replacement
  }) _obtainReplacement(
    Map<String, dynamic> mergeJson,
  ) {
    final List<Map<String, dynamic>> replacements = mergeJson['replacement'];
    final wordReplacements = replacements
        .map(
          (map) => map.values.map(
            (e) {
              if (e is Map<String, dynamic>) {
                return e;
              }
              return null;
            },
          ).fold<Map<String, dynamic>>(
            {},
            (previousValue, element) => {...previousValue, ...?element},
          ),
        )
        .toList();

    final groupByLocalesAndNoLocales = wordReplacements.groupListsBy(
      (element) {
        return element['locales'] != null;
      },
    );

    return (
      localeReplacement: groupByLocalesAndNoLocales[true] ?? [],
      replacement: groupByLocalesAndNoLocales[false] ?? []
    );
  }

  ({
    List<Map<String, dynamic>> commonLocalization,
    List<Map<String, dynamic>> replacementLocalization,
  })? obtainLocalizations(
    Map<String, dynamic> mergeJson,
    Map<String, dynamic> allJson,
  ) {
    try {
      final allLocalizations = (allJson['localizations'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
      final mergeLocalizations = (mergeJson['localizations'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();

      final locale = allLocalizations.any(
        (element) => element['locale'] == null,
      );

      if (locale) {
        final otherContainsLocale = allLocalizations.any(
          (element) => element['locale'] != null,
        );

        if (otherContainsLocale) {
          print(
            "Warning: Maybe you have localizations without locale key, this break the json schema arb_localization for localization. If your merge if not from localization you can ignore this warning"
                .colorizeMessage(PrinterStringColor.yellow, emoji: "🚨"),
          );
        }
        throw UnsupportedError(
          'It cannot be localization because there have not locale',
        );
      }

      return (
        commonLocalization: allLocalizations,
        replacementLocalization: mergeLocalizations
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
      "Proceeded to change match keys"
          .colorizeMessage(PrinterStringColor.magenta, emoji: "🔛"),
    );
    for (var merges in mergeJson.entries) {
      allJson.update(
        merges.key,
        (value) => merges.value,
        ifAbsent: () {
          return merges.value;
        },
      );
    }
  }

  void _replaceByLocalizationListSchema(
    List<Map<String, dynamic>> allLocalizations,
    List<Map<String, dynamic>> mergeLocalizations, {
    required List<Map<String, dynamic>> replacementWithLocale,
  }) {
    print(
      "Localizations find, proceeded to change internal localizations"
          .colorizeMessage(PrinterStringColor.magenta, emoji: "🔛"),
    );

    for (int i = 0; i < mergeLocalizations.length; i++) {
      final mergeInternal = mergeLocalizations[i];
      final internalLocale = mergeInternal['locale'];

      final internalLocalizationWithAllLocalizations = allLocalizations
          .firstWhereOrNull((element) => element['locale'] == internalLocale);
      final replacementOfInternalLocale = replacementWithLocale.where(
        (element) {
          if (element['locales'] case final locales? when locales is List) {
            return (locales.contains(internalLocale) &&
                element['word'] is String &&
                element['replacement'] is String);
          }
          return element['locales'];
        },
      ).toList();

      if (internalLocalizationWithAllLocalizations != null) {
        //In all localizations exist the merge language
        _deleteAndUpdateInternalLocalization(
          allLocalizations,
          internalLocalizationWithAllLocalizations,
          mergeInternal,
          replacementOfInternalLocale,
        );
        allLocalizations.add(internalLocalizationWithAllLocalizations);
      }
    }
  }

  ///Delete localization for father localizations and added again with the merge updates
  void _deleteAndUpdateInternalLocalization(
    List<Map<String, dynamic>> allLocalizations,
    Map<String, dynamic> internalLocalizationWithAllLocalizations,
    Map<String, dynamic> mergeInternal,
    List<Map<String, dynamic>> replacementOfInternalLocale,
  ) {
    allLocalizations.removeWhere(
      (element) => element == internalLocalizationWithAllLocalizations,
    );
    for (var merges in mergeInternal.entries) {
      print(merges);
      internalLocalizationWithAllLocalizations.update(
        merges.key,
        (value) {
          print(
            "Update {${merges.key}:${merges.value}.}"
                .colorizeMessage(PrinterStringColor.green, emoji: "✅"),
          );
          String resultValue = merges.value;

          for (var replacements in replacementOfInternalLocale) {
            final word = replacements['word'];
            final replacement = replacements['replacement'];
            if (word is String && replacement is String) {
              resultValue = resultValue.replaceAll(word, replacement);
            }
          }

          return resultValue;
        },
        ifAbsent: () {
          print(
            "Added ${merges.key} with value ${merges.value}. This key doesn't exist in the previous json"
                .colorizeMessage(PrinterStringColor.red, emoji: "🚨"),
          );
          String resultValue = merges.value;

          for (var replacements in replacementOfInternalLocale) {
            final word = replacements['word'];
            final replacement = replacements['replacement'];
            if (word is String && replacement is String) {
              resultValue.replaceAll(word, replacement);
            }
          }

          return resultValue;
        },
      );
    }
  }
}
