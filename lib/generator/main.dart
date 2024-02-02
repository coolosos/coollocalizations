import 'dart:io';

import 'package:args/args.dart';
import 'package:coollocalizations/generator/arb_class_generate_by_schema.dart';
import 'package:coollocalizations/generator/schema_update.dart';

import 'arb_arguments.dart';
import 'package:path/path.dart' as path;

Future<void> main(List<String> arguments) async {
  final ArgParser parser = ArbArguments().parser;

  if (arguments.isNotEmpty && arguments[0] == 'help') {
    stdout.writeln(parser.usage);
    return;
  }

  final ArgResults result = parser.parse(arguments);

  final File schemaFile = File(
    path.canonicalize(
      path.absolute(
        result[ArbArguments.schemaKey],
      ),
    ),
  );

  final String className = result[ArbArguments.nameKey];

  final arbGenerator = ArbClassGenerateBySchema(
    schemaFile: schemaFile,
    resultFile: File("$className.dart"),
  );

  arbGenerator.run();

  final schemaUpdater = SchemaUpdater(schemaFile: schemaFile)
    ..updateRequirements();

  final String? newSchemaLocation = result[ArbArguments.copySchemaLocation];
  if (!(newSchemaLocation == null || newSchemaLocation.isEmpty)) {
    schemaUpdater.copySchemaOnLocation(copyLocation: newSchemaLocation);
  }
}
