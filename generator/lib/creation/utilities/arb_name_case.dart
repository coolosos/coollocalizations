import 'dart:io';
import 'package:path/path.dart' as p;

final class ArbNameCase {
  ArbNameCase({required File file})
      : path = p.dirname(file.path),
        name = p.basenameWithoutExtension(file.path);

  final String path;
  final String name;
  String get className {
    return name.snakeCaseToCamelCase() ?? '';
  }
}

extension StringCases on String? {
  String? toLowerCamelCase() {
    final text = this;
    if (text == null || text.isEmpty) {
      return text;
    }

    final String firstChar = text[0].toLowerCase();

    final String restOfString = text.substring(1);

    return firstChar + restOfString;
  }

  String? toSnakeCase() {
    final String? camelCaseString = this;
    if (camelCaseString == null || camelCaseString.isEmpty) {
      return camelCaseString;
    }

    String snakeCase = camelCaseString.replaceAllMapped(
      RegExp(r'(?<!^)([A-Z])'),
      (Match m) => '_${m.group(1)}',
    );

    return snakeCase.toLowerCase();
  }

  String? snakeCaseToCamelCase() {
    final String? snakeCaseString = this;
    if (snakeCaseString == null || snakeCaseString.isEmpty) {
      return snakeCaseString;
    }

    final parts = snakeCaseString.split('_');

    final camelCaseParts = parts.map((part) {
      if (part.isEmpty) {
        return '';
      }

      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).toList();

    return camelCaseParts.join();
  }
}
