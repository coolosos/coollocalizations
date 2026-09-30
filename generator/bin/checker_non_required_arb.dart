import 'dart:async';
import 'dart:io';

import 'package:coollocalizations_generator/checker/non_required/checker_non_required_arguments.dart';
import 'package:coollocalizations_generator/checker/non_required/checker_non_required_keys.dart';
import 'package:coollocalizations_generator/utilities/argument_reader.dart';
import 'package:coollocalizations_generator/utilities/printer_helper.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  try {
    final parser = CheckerNonRequiredArguments().parser;

    if (arguments.isNotEmpty && arguments[0] == 'help') {
      stdout.writeln(parser.usage);
      return;
    }

    final result = parser.parse(arguments);

    final schemaFile = File(
      p.canonicalize(
        p.absolute(
          readStringArg(result, CheckerNonRequiredArguments.arbSchema),
        ),
      ),
    );

    final generatorAwaitList = <Future<void>>[];

    final className = readStringArg(
      result,
      CheckerNonRequiredArguments.outputFileLocalization,
    );

    final checkerNonUsedFiles = CheckerNonRequiredKeys(
      schemaFile: schemaFile,
      resultFile: File('$className.txt'),
      searchFile: File(
        p.canonicalize(
          p.absolute(
            readStringArg(result, CheckerNonRequiredArguments.searchFile),
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
