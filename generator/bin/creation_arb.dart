import 'dart:async';
import 'dart:io';

import 'package:coollocalizations_generator/creation/arb_arguments.dart';
import 'package:coollocalizations_generator/creation/arb_class_generate_by_schema.dart';
import 'package:coollocalizations_generator/creation/schema_update.dart';
import 'package:coollocalizations_generator/utilities/argument_reader.dart';
import 'package:coollocalizations_generator/utilities/printer_helper.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  try {
    final parser = ArbArguments().parser;

    if (arguments.isNotEmpty && arguments[0] == 'help') {
      stdout.writeln(parser.usage);
      return;
    }

    final result = parser.parse(arguments);

    final schemaFile = File(
      p.canonicalize(p.absolute(readStringArg(result, ArbArguments.schemaKey))),
    );

    final generatorList = <Future<void> Function()>[];

    final className = readStringArg(result, ArbArguments.nameKey);

    final arbGenerator = ArbClassGenerateBySchema(
      schemaFile: schemaFile,
      resultFile: File('$className.dart'),
      isForMerge: false,
    );

    generatorList.add(arbGenerator.run);

    final arbRemoteGenerator = ArbClassGenerateBySchema(
      schemaFile: schemaFile,
      resultFile: File('${className}_merge.dart'),
      isForMerge: true,
    );

    generatorList.add(arbRemoteGenerator.run);

    final schemaUpdater = SchemaUpdater(schemaFile: schemaFile);

    await schemaUpdater.createMergeSchema(
      path: readStringArg(result, ArbArguments.modificationSchemaLocation),
    );

    await schemaUpdater.updateRequirements();

    final newSchemaLocation = readOptionalStringArg(
      result,
      ArbArguments.copySchemaLocation,
    );
    if (newSchemaLocation != null && newSchemaLocation.isNotEmpty) {
      generatorList.add(
        () =>
            schemaUpdater.copySchemaOnLocation(copyLocation: newSchemaLocation),
      );
    }

    await Future.wait(generatorList.map((generator) => generator()));
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
