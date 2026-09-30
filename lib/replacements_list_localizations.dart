import 'package:json_annotation/json_annotation.dart';

import 'extension/replace_extension.dart';

part 'replacements_list_localizations.g.dart';

@JsonSerializable()
class ReplacementsListLocalizations {
  const new({required this.value, required this.dateTimeReplacements});

  factory fromJson(Map<String, dynamic> json) =>
      _$ReplacementsListLocalizationsFromJson(json);

  final List<String> value;
  final Map<String, String>? dateTimeReplacements;

  List<String> run(
    Map<String, dynamic> substitutesWords, {
    required String? locale,
  }) {
    return [
      for (final text in value)
        text.substitute(
          substitutesWords.formatDateTime(dateTimeReplacements, locale: locale),
        ),
    ];
  }
}
