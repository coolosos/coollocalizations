import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import '../creation/arb_arguments.dart';
import '../creation/arb_class_generate_by_schema.dart';
import '../creation/schema_update.dart';
import '../utilities/printer_helper.dart';

import 'package:path/path.dart' as path;

Future<void> creation(List<String> arguments) async {
  try {
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
