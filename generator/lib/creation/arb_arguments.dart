import 'package:args/args.dart';

class ArbArguments {
  static const schemaKey = 'schema';

  static const nameKey = 'source-directory';

  static const copySchemaLocation = 'copy-schema-location';

  static const modificationSchemaLocation = 'modification-schema';

  final ArgParser parser = ArgParser()
    ..addOption(
      schemaKey,
      abbr: 's',
      help: 'Schema Json',
      mandatory: true,
    )
    ..addOption(
      copySchemaLocation,
      abbr: 'c',
      aliases: ["copySchema"],
      help: 'Copy schema on location',
    )
    ..addOption(
      modificationSchemaLocation,
      abbr: 'm',
      help: 'Modification path name',
      defaultsTo: "modification_schema.json",
    )
    ..addOption(
      nameKey,
      abbr: 'n',
      help: 'Name of the default directory',
      defaultsTo: "arb_localization",
    );
}
