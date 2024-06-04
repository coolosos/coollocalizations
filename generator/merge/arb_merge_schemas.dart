import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';

import '../utilities/printer_helper.dart';

final class ArbMergeSchemas with PrinterHelper {
  const ArbMergeSchemas({
    required this.allLocalizations,
    required this.mergeLocalizations,
    required this.outputFile,
  });

  final File allLocalizations;
  final File mergeLocalizations;

  final File outputFile;

  Future<void> run() async {
    title("Arb Merge Json");
    print("Reading common json"
        .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"));
    final String all = await allLocalizations.readAsString();
    final Map<String, dynamic> allJson = json.decode(all);
    print("Reading replacement json"
        .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"));
    final merge = await mergeLocalizations.readAsString();
    final Map<String, dynamic> mergeJson = json.decode(merge);

    if (mergeJson['checkSchema'] != null) {
      allJson['\$schema'] = mergeJson['checkSchema'];
    }

    if (allJson['localizations'] != null &&
        mergeJson['localizations'] != null) {
      _replaceByLocalizationListSchema(allJson, mergeJson);
    } else {
      _replaceByMatchKeys(mergeJson, allJson);
    }

    var encoder = const JsonEncoder.withIndent("  ");

    outputFile.writeAsStringSync(encoder.convert(allJson));
    print("Creation file success"
        .colorizeMessage(PrinterStringColor.green, emoji: "✨"));
  }

  void _replaceByMatchKeys(
      Map<String, dynamic> mergeJson, Map<String, dynamic> allJson) {
    print("No Localizations find, proceeded to change match keys"
        .colorizeMessage(PrinterStringColor.magenta, emoji: "🔛"));
    for (var merges in mergeJson.entries) {
      allJson.update(
        merges.key,
        (value) => merges.value,
        ifAbsent: () => allJson.addAll({merges.key: merges.value}),
      );
    }
  }

  void _replaceByLocalizationListSchema(
      Map<String, dynamic> allJson, Map<String, dynamic> mergeJson) {
    print("Localizations find, proceeded to change internal localizations"
        .colorizeMessage(PrinterStringColor.magenta, emoji: "🔛"));

    final allLocalizations = (allJson['localizations'] as List)
        .whereType<Map<String, dynamic>>()
        .toList();
    final mergeLocalizations = (mergeJson['localizations'] as List)
        .whereType<Map<String, dynamic>>()
        .toList();

    for (int i = 0; i < mergeLocalizations.length; i++) {
      final mergeInternal = mergeLocalizations[i];
      final internalLocale = mergeInternal['locale'];

      final internalLocalizationWithAllLocalizations = allLocalizations
          .firstWhereOrNull((element) => element['locale'] == internalLocale);

      if (internalLocalizationWithAllLocalizations != null) {
        //In all localizations exist the merge language
        _deleteAndUpdateInternalLocalization(allLocalizations,
            internalLocalizationWithAllLocalizations, mergeInternal);
        allLocalizations.add(internalLocalizationWithAllLocalizations);
      }
    }
  }

  ///Delete localization for father localizations and added again with the merge updates
  void _deleteAndUpdateInternalLocalization(
      List<Map<String, dynamic>> allLocalizations,
      Map<String, dynamic> internalLocalizationWithAllLocalizations,
      Map<String, dynamic> mergeInternal) {
    allLocalizations.removeWhere(
        (element) => element == internalLocalizationWithAllLocalizations);
    for (var merges in mergeInternal.entries) {
      print(merges);
      internalLocalizationWithAllLocalizations.update(
        merges.key,
        (value) {
          print("Update {${merges.key}:${merges.value}.}"
              .colorizeMessage(PrinterStringColor.green, emoji: "✅"));
          return merges.value;
        },
        ifAbsent: () {
          print(
              "Added ${merges.key} with value ${merges.value}. This key doesn't exist in the previous json"
                  .colorizeMessage(PrinterStringColor.red, emoji: "🚨"));
          internalLocalizationWithAllLocalizations.addEntries([merges]);
        },
      );
    }
  }
}
