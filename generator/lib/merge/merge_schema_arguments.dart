import 'package:args/args.dart';

class MergeSchemasArguments {
  static const allLocalizations = 'allLocalizations';

  static const mergeLocalizations = 'mergeLocalizations';

  static const outputFile = 'outputFile';

  static const typology = 'typology';
  static const replacements = 'replacements';

  final parser = ArgParser()
    ..addOption(
      allLocalizations,
      abbr: 'a',
      aliases: const ['all'],
      help: 'All json file',
      mandatory: true,
    )
    ..addOption(
      mergeLocalizations,
      abbr: 'm',
      aliases: const ['merge'],
      help: 'Merge json file',
      mandatory: true,
    )
    ..addOption(
      outputFile,
      abbr: 'o',
      aliases: const ['output'],
      mandatory: true,
      help: 'Output file of all json',
    )
    ..addOption(
      typology,
      aliases: const ['type'],
      allowed: const ['localization', 'any'],
      defaultsTo: 'any',
      help: 'Output file of all json',
    )
    ..addOption(
      replacements,
      aliases: const ['replacements'],
      abbr: 'r',
      help: 'Array of words replacements',
    );
}
