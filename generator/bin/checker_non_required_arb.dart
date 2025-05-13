// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:coollocalizations_generator/checker/non_required/checker_non_required_arguments.dart';
import 'package:coollocalizations_generator/checker/non_required/checker_non_required_keys.dart';
import 'package:coollocalizations_generator/utilities/printer_helper.dart';

import 'package:path/path.dart' as path;

Future<void> main(List<String> arguments) async {
  try {
    final ArgParser parser = CheckerNonRequiredArguments().parser;

    if (arguments.isNotEmpty && arguments[0] == 'help') {
      stdout.writeln(parser.usage);
      return;
    }

    final ArgResults result = parser.parse(arguments);

    final File schemaFile = File(
      path.canonicalize(
        path.absolute(
          result[CheckerNonRequiredArguments.arbSchema],
        ),
      ),
    );

    final List<Future> generatorAwaitList = [];

    final String className =
        result[CheckerNonRequiredArguments.outputFileLocalization];

    final checkerNonUsedFiles = CheckerNonRequiredKeys(
      schemaFile: schemaFile,
      resultFile: File("$className.txt"),
      searchFile: File(
        path.canonicalize(
          path.absolute(
            result[CheckerNonRequiredArguments.searchFile],
          ),
        ),
      ),
    );

    generatorAwaitList.add(checkerNonUsedFiles.run());

    await Future.wait(generatorAwaitList);
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
