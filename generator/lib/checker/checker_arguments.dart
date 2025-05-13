import 'package:args/args.dart';

final class CheckerArguments {
  static const arbSchema = 'arb-schema';
  static const nameKey = 'source-directory';
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
      nameKey,
      abbr: 's',
      help: 'Search directory',
      mandatory: true,
    );
}
