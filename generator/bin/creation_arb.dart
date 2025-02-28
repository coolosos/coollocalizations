import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:coollocalizations_generator/creation/arb_arguments.dart';
import 'package:coollocalizations_generator/creation/arb_class_generate_by_schema.dart';
import 'package:coollocalizations_generator/creation/schema_update.dart';

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

  final List<Future> generatorAwaitList = [];

  final String className = result[ArbArguments.nameKey];

  final arbGenerator = ArbClassGenerateBySchema(
    schemaFile: schemaFile,
    resultFile: File("$className.dart"),
    isForMerge: false,
  );

  generatorAwaitList.add(arbGenerator.run());

  final arbRemoteGenerator = ArbClassGenerateBySchema(
    schemaFile: schemaFile,
    resultFile: File("${className}_merge.dart"),
    isForMerge: true,
  );

  generatorAwaitList.add(arbRemoteGenerator.run());

  final schemaUpdater = SchemaUpdater(schemaFile: schemaFile);

  await schemaUpdater.createMergeSchema(
    path: result[ArbArguments.modificationSchemaLocation],
  );

  await schemaUpdater.updateRequirements();

  final String? newSchemaLocation = result[ArbArguments.copySchemaLocation];
  if (!(newSchemaLocation == null || newSchemaLocation.isEmpty)) {
    generatorAwaitList.add(
      schemaUpdater.copySchemaOnLocation(copyLocation: newSchemaLocation),
    );
  }

  await Future.wait(generatorAwaitList);

  exit(1);
}
