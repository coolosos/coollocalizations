import 'package:intl/intl.dart';

extension ReplaceInternalization on String {
  String substitute(Map<String, String> bannedWords) {
    RegExp regexSubstituteWords = RegExp(
      "(${bannedWords.keys.join("|")})",
      caseSensitive: false,
    );

    return replaceAllMapped(
      regexSubstituteWords,
      (match) {
        final newWorld = bannedWords[match[0]];
        if (newWorld is String && match.input.contains(newWorld)) {
          return '';
        }
        return newWorld ?? '';
      },
    );
  }
}

extension SubtitionFormatDateTime on Map<String, dynamic> {
  Map<String, String> formatDateTime(
      Map<String, String>? dateTimeReplacements) {
    final List<_DateTimeReplacements> dateTimesSubtituion = [];
    final iterableSubtituions = Map.from(this);
    for (var element in iterableSubtituions.entries) {
      final String? dateFormat = dateTimeReplacements?[element.key];
      if (element.value is DateTime && dateFormat != null) {
        dateTimesSubtituion.add(_DateTimeReplacements(
            key: element.key, time: element.value, format: dateFormat));
        this.remove(element.key);
      }
    }
    final Iterable<Map<String, String>> transformations =
        dateTimesSubtituion.map((e) => e.transform());
    final Map<String, String> dateTimeTransformations = {};
    for (Map<String, String> element in transformations) {
      dateTimeTransformations.addAll(element);
    }
    final Map<String, String> subtitions = {
      ...this,
      ...dateTimeTransformations
    };
    return subtitions;
  }
}

final class _DateTimeReplacements {
  final String key;
  final DateTime time;
  final String format;
  final String? locale;

  const _DateTimeReplacements({
    required this.key,
    required this.time,
    required this.format,
    required this.locale,
  });

  Map<String, String> transform() {
    final fDateTime = DateFormat(format, locale);
    return {key: fDateTime.format(time)};
  }
}
