import 'package:args/args.dart';

final class CheckerNonRequiredArguments {
  static const arbSchema = 'arb-schema';
  static const searchFile = 'search-file';
  static const outputFileLocalization = 'output-directory';

  final ArgParser parser = ArgParser()
    ..addOption(
      arbSchema,
      abbr: 'a',
      help: 'Schema of arb',
      mandatory: true,
    )
    ..addOption(
      outputFileLocalization,
      abbr: 'o',
      aliases: ["output"],
      help: 'output localization',
      mandatory: true,
    )
    ..addOption(
      searchFile,
      abbr: 's',
      help: 'Search file',
      mandatory: true,
    );
}
