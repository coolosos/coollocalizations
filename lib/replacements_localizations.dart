import 'package:json_annotation/json_annotation.dart';

import 'extension/replace_extension.dart';

part 'replacements_localizations.g.dart';

@JsonSerializable()
class ReplacementsLocalizations {
  const new({required this.value, required this.dateTimeReplacements});

  factory fromJson(Map<String, dynamic> json) =>
      _$ReplacementsLocalizationsFromJson(json);

  final String value;
  final Map<String, String>? dateTimeReplacements;

  String run(Map<String, dynamic> substitutesWords, {required String? locale}) {
    return value.substitute(
      substitutesWords.formatDateTime(dateTimeReplacements, locale: locale),
    );
  }
}
