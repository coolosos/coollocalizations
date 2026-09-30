import 'package:intl/intl.dart';

extension ReplaceInternalization on String {
  String substitute(Map<String, String> substitutionMap) {
    final regexSubstituteWords = RegExp(
      '(${substitutionMap.keys.join('|')})',
      caseSensitive: false,
    );

    return replaceAllMapped(
      regexSubstituteWords,
      (match) => substitutionMap[match[0]] ?? '',
    );
  }
}

extension SubstitutionFormatDateTime on Map<String, dynamic> {
  Map<String, String> formatDateTime(
    Map<String, String>? dateTimeReplacements, {
    required String? locale,
  }) {
    final dateTimesSubstitution = <_DateTimeReplacements>[];
    final iterableSubstitutions = Map<String, dynamic>.from(this);
    for (final element in iterableSubstitutions.entries) {
      final dateFormat = dateTimeReplacements?[element.key];
      final value = element.value;
      if (value is DateTime && dateFormat != null) {
        dateTimesSubstitution.add(
          _DateTimeReplacements(
            key: element.key,
            time: value,
            format: dateFormat,
            locale: locale,
          ),
        );
        remove(element.key);
      }
    }
    final dateTimeTransformations = <String, String>{
      for (final replacement in dateTimesSubstitution)
        ...replacement.transform(),
    };
    return {
      for (final entry in entries) entry.key: entry.value.toString(),
      ...dateTimeTransformations,
    };
  }
}

final class _DateTimeReplacements {
  const new({
    required this.key,
    required this.time,
    required this.format,
    required this.locale,
  });
  final String key;
  final DateTime time;
  final String format;
  final String? locale;

  Map<String, String> transform() {
    final fDateTime = DateFormat(format, locale);
    return {key: fDateTime.format(time)};
  }
}
