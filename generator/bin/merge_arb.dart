import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:coollocalizations_generate/merge/arb_merge_schemas.dart';
import 'package:coollocalizations_generate/merge/merge_schema_arguments.dart';

import 'package:path/path.dart' as path;

Future<void> main(List<String> arguments) async {
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
  );

  await arbMergeSchemas.run();

  exit(1);
}
