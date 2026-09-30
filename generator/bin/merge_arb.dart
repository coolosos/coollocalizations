import 'dart:async';
import 'dart:io';

import 'package:coollocalizations_generator/merge/arb_merge_schemas.dart';
import 'package:coollocalizations_generator/merge/merge_schema_arguments.dart';
import 'package:coollocalizations_generator/utilities/argument_reader.dart';
import 'package:coollocalizations_generator/utilities/printer_helper.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  try {
    final parser = MergeSchemasArguments().parser;

    if (arguments.isNotEmpty && arguments[0] == 'help') {
      stdout.writeln(parser.usage);
      return;
    }

    final result = parser.parse(arguments);

    final allLocalizationsFile = File(
      p.canonicalize(
        p.absolute(
          readStringArg(result, MergeSchemasArguments.allLocalizations),
        ),
      ),
    );
    final mergeLocalizations = File(
      p.canonicalize(
        p.absolute(
          readStringArg(result, MergeSchemasArguments.mergeLocalizations),
        ),
      ),
    );

    final outputFile = File(
      readStringArg(result, MergeSchemasArguments.outputFile),
    );

    final arbMergeSchemas = ArbMergeSchemas(
      allLocalizations: allLocalizationsFile,
      mergeLocalizations: mergeLocalizations,
      outputFile: outputFile,
      typology: TypologyMerge.fromString(
        readOptionalStringArg(result, MergeSchemasArguments.typology),
      ),
      additionalReplacements: readReplacementsArg(
        result,
        MergeSchemasArguments.replacements,
      ),
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
