import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:coollocalizations_generator/merge/arb_merge_schemas.dart';
import 'package:coollocalizations_generator/merge/merge_schema_arguments.dart';
import 'package:coollocalizations_generator/utilities/printer_helper.dart';

import 'package:path/path.dart' as path;

Future<void> main(List<String> arguments) async {
  try {
    final ArgParser parser = MergeSchemasArguments().parser;

    if (arguments.isNotEmpty && arguments[0] == 'help') {
      stdout.writeln(parser.usage);
      return;
    }

    final ArgResults result = parser.parse(arguments);

    final File allLocalizationsFile = File(
      path.canonicalize(
        path.absolute(
          result[MergeSchemasArguments.allLocalizations],
        ),
      ),
    );
    final File mergeLocalizations = File(
      path.canonicalize(
        path.absolute(
          result[MergeSchemasArguments.mergeLocalizations],
        ),
      ),
    );

    final File outputFile = File(result[MergeSchemasArguments.outputFile]);

    final ArbMergeSchemas arbMergeSchemas = ArbMergeSchemas(
      allLocalizations: allLocalizationsFile,
      mergeLocalizations: mergeLocalizations,
      outputFile: outputFile,
      typology:
          TypologyMerge.fromString(result[MergeSchemasArguments.typology]),
    );

    await arbMergeSchemas.run();
  } catch (e) {
    PrinterHelper().topDivider();
    print(
      'Error execution'.colorizeMessage(PrinterStringColor.red, emoji: '🚨'),
    );
    PrinterHelper().bottomDivider();
    print(e);
    exit(1);
  }

  exit(0);
}

extension StringToMap on String {
  Map<String, String>? toMapOfReplacements() {
    if (isEmpty) {
      return null;
    }
    try {
      final pairSplit = split(',');
      final Map<String, String> map = {};
      for (var pair in pairSplit) {
        final keyValue = pair.split(':');
        if (keyValue.first.trim() case final key when key.isNotEmpty) {
          if (keyValue.last.trim() case final value when value.isNotEmpty) {
            map.addAll({key: value});
          }
        }
      }
      if (map.isEmpty) {
        return null;
      }
      return map;
    } catch (e) {
      return null;
    }
  }
}
