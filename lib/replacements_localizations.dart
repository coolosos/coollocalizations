import 'package:coollocalizations/extension/replace_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part "replacements_localizations.g.dart";

@JsonSerializable()
class ReplacementsLocalizations {
  const ReplacementsLocalizations({
    required this.value,
    required this.dateTimeReplacements,
  });

  factory ReplacementsLocalizations.fromJson(
    Map<String, dynamic> json,
  ) {
    final object = _$ReplacementsLocalizationsFromJson(json);
    return ReplacementsLocalizations(
      value: object.value,
      dateTimeReplacements: object.dateTimeReplacements,
    );
  }

  final String value;
  final Map<String, String>? dateTimeReplacements;

  String run(
    Map<String, dynamic> substitutesWords, {
    required String? locale,
  }) {
    return value.substitute(substitutesWords.formatDateTime(
      dateTimeReplacements,
      locale: locale,
    ));
  }
}
