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

    if (allJson['localizations'] != null &&
        mergeJson['localizations'] != null) {
      print("Localizations find, proceded to change internal localizations"
          .colorizeMessage(PrinterStringColor.magenta, emoji: "🔛"));

      final iterableAll = (allJson['localizations'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
      final iterableMerge = (mergeJson['localizations'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();

      for (int i = 0; i < iterableMerge.length; i++) {
        final mergeInternal = iterableMerge[i];
        final internalLocale = mergeInternal['locale'];

        final internalAll = iterableAll
            .firstWhereOrNull((element) => element['locale'] == internalLocale);

        if (internalAll != null) {
          iterableAll.removeWhere((element) => element == internalAll);
          for (var merges in mergeInternal.entries) {
            print(merges);
            internalAll.update(
              merges.key,
              (value) => merges.value,
              ifAbsent: () {
                print(
                    "Added ${merges.key} with value ${merges.value}. This key doesn't exist in the previous json"
                        .colorizeMessage(PrinterStringColor.red, emoji: "🚨"));
                internalAll.addEntries([merges]);
              },
            );
          }
          print(internalAll);
          iterableAll.add(internalAll);
        }
      }
    } else {
      print("No Localizations find, proceded to change match keys"
          .colorizeMessage(PrinterStringColor.magenta, emoji: "🔛"));
      for (var merges in mergeJson.entries) {
        allJson.update(
          merges.key,
          (value) => merges.value,
          ifAbsent: () => allJson.addAll({merges.key: merges.value}),
        );
      }
    }

    var encoder = const JsonEncoder.withIndent("  ");

    outputFile.writeAsStringSync(encoder.convert(allJson));
    print("Creation file success"
        .colorizeMessage(PrinterStringColor.green, emoji: "✨"));
  }
}
