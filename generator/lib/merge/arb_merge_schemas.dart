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
    required this.replacementWords,
  });

  final File allLocalizations;
  final File mergeLocalizations;

  final File outputFile;

  final TypologyMerge typology;

  final Map<String, String>? replacementWords;

  Future<void> run() async {
    title("Merge Json");
    print(
      "Reading common json"
          .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"),
    );
    final String all = await allLocalizations.readAsString();
    final Map<String, dynamic> allJson = json.decode(all);
    print(
      "Reading replacement json"
          .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"),
    );
    final merge = await mergeLocalizations.readAsString();
    final Map<String, dynamic> mergeJson = json.decode(merge);

    if (mergeJson['checkSchema'] != null) {
      allJson['\$schema'] = mergeJson['checkSchema'];
    }

    final fromLocalization = obtainLocalizations(mergeJson, allJson);

    if (fromLocalization case final fromLocalization?) {
      _replaceByLocalizationListSchema(
        fromLocalization.commonLocalization,
        fromLocalization.replacementLocalization,
      );
    } else {
      _replaceByMatchKeys(mergeJson, allJson);
    }

    var encoder = const JsonEncoder.withIndent("  ");

    String fileAsString = encoder.convert(allJson);

    if (replacementWords?.entries case final entries? when entries.isNotEmpty) {
      for (var replacement in entries) {
        fileAsString =
            fileAsString.replaceAll(replacement.key, replacement.value);
      }
    }

    outputFile.writeAsStringSync(fileAsString);
    print(
      "Creation file success"
          .colorizeMessage(PrinterStringColor.green, emoji: "✨"),
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
    List<Map<String, dynamic>> mergeLocalizations,
  ) {
    print(
      "Localizations find, proceeded to change internal localizations"
          .colorizeMessage(PrinterStringColor.magenta, emoji: "🔛"),
    );

    for (int i = 0; i < mergeLocalizations.length; i++) {
      final mergeInternal = mergeLocalizations[i];
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
    for (var merges in mergeInternal.entries) {
      print(merges);
      internalLocalizationWithAllLocalizations.update(
        merges.key,
        (value) {
          print(
            "Update {${merges.key}:${merges.value}.}"
                .colorizeMessage(PrinterStringColor.green, emoji: "✅"),
          );
          return merges.value;
        },
        ifAbsent: () {
          print(
            "Added ${merges.key} with value ${merges.value}. This key doesn't exist in the previous json"
                .colorizeMessage(PrinterStringColor.red, emoji: "🚨"),
          );
          internalLocalizationWithAllLocalizations.addEntries([merges]);
        },
      );
    }
  }
}
