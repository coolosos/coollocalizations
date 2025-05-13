// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:coollocalizations_generator/checker/checker_arguments.dart';
import 'package:coollocalizations_generator/checker/checker_non_used_files.dart';
import 'package:coollocalizations_generator/creation/arb_arguments.dart';
import 'package:coollocalizations_generator/utilities/printer_helper.dart';

import 'package:path/path.dart' as path;

Future<void> main(List<String> arguments) async {
  try {
    final ArgParser parser = CheckerArguments().parser;

    if (arguments.isNotEmpty && arguments[0] == 'help') {
      stdout.writeln(parser.usage);
      return;
    }

    final ArgResults result = parser.parse(arguments);

    final File schemaFile = File(
      path.canonicalize(
        path.absolute(
          result[CheckerArguments.arbSchema],
        ),
      ),
    );

    final List<Future> generatorAwaitList = [];

    final String className = result[ArbArguments.nameKey];

    final checkerNonUsedFiles = CheckerNonUsedFiles(
      schemaFile: schemaFile,
      resultFile: File("$className.dart"),
      searchDirectory: Directory(
        path.canonicalize(
          path.absolute(
            result[CheckerArguments.outputFileLocalization],
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
