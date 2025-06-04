import 'package:args/args.dart';

class MergeSchemasArguments {
  static const allLocalizations = 'allLocalizations';

  static const mergeLocalizations = 'mergeLocalizations';

  static const outputFile = 'outputFile';

  static const typology = 'typology';

  final ArgParser parser = ArgParser()
    ..addOption(
      allLocalizations,
      abbr: 'a',
      aliases: ["all"],
      help: 'All json file',
      mandatory: true,
    )
    ..addOption(
      mergeLocalizations,
      abbr: 'm',
      aliases: ["merge"],
      help: 'Merge json file',
      mandatory: true,
    )
    ..addOption(
      outputFile,
      abbr: 'o',
      aliases: ["output"],
      mandatory: true,
      help: 'Output file of all json',
    )
    ..addOption(
      typology,
      aliases: ["type"],
      allowed: ['localization', "any"],
      defaultsTo: 'any',
      help: 'Output file of all json',
    );
}
