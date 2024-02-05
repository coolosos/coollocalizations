import 'package:args/args.dart';

class MergeSchemasArguments {
  static const allLocalizations = 'allLocalizations';

  static const mergeLocalizations = 'mergeLocalizations';

  static const outputFile = 'outputFile';

  final ArgParser parser = ArgParser()
    ..addOption(
      allLocalizations,
      abbr: 'a',
      aliases: ["all"],
      help: 'All localizations file',
      mandatory: true,
    )
    ..addOption(
      allLocalizations,
      abbr: 'm',
      aliases: ["merge"],
      help: 'Merge localizations file',
      mandatory: true,
    )
    ..addOption(
      outputFile,
      abbr: 'o',
      aliases: ["output"],
      mandatory: true,
      help: 'Output file of all json',
    );
}
