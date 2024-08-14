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

extension substitutionFormatDateTime on Map<String, dynamic> {
  Map<String, String> formatDateTime(
    Map<String, String>? dateTimeReplacements, {
    required String? locale,
  }) {
    final List<_DateTimeReplacements> dateTimesSubstitution = [];
    final iterableSubstitutions = Map.from(this);
    for (var element in iterableSubstitutions.entries) {
      final String? dateFormat = dateTimeReplacements?[element.key];
      if (element.value is DateTime && dateFormat != null) {
        dateTimesSubstitution.add(
          _DateTimeReplacements(
            key: element.key,
            time: element.value,
            format: dateFormat,
            locale: locale,
          ),
        );
        this.remove(element.key);
      }
    }
    final Iterable<Map<String, String>> transformations =
        dateTimesSubstitution.map((e) => e.transform());
    final Map<String, String> dateTimeTransformations = {};
    for (Map<String, String> element in transformations) {
      dateTimeTransformations.addAll(element);
    }
    return {
      ...this,
      ...dateTimeTransformations,
    };
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
