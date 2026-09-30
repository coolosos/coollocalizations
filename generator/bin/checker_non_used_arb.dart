import 'dart:async';
import 'dart:io';

import 'package:coollocalizations_generator/checker/non_used/checker_non_used_arguments.dart';
import 'package:coollocalizations_generator/checker/non_used/checker_non_used_keys.dart';
import 'package:coollocalizations_generator/utilities/argument_reader.dart';
import 'package:coollocalizations_generator/utilities/printer_helper.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  try {
    final parser = CheckerNonUsedArguments().parser;

    if (arguments.isNotEmpty && arguments[0] == 'help') {
      stdout.writeln(parser.usage);
      return;
    }

    final result = parser.parse(arguments);

    final schemaFile = File(
      p.canonicalize(
        p.absolute(readStringArg(result, CheckerNonUsedArguments.arbSchema)),
      ),
    );

    final generatorAwaitList = <Future<void>>[];

    final className = readStringArg(
      result,
      CheckerNonUsedArguments.outputFileLocalization,
    );

    final checkerNonUsedFiles = CheckerNonUsedKeys(
      schemaFile: schemaFile,
      resultFile: File('$className.txt'),
      searchDirectory: Directory(
        p.canonicalize(
          p.absolute(
            readStringArg(result, CheckerNonUsedArguments.searchDirectory),
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
