import 'package:coollocalizations/extension/replace_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part "multi_choice_replacements_localizations.g.dart";

@JsonSerializable()
class MultiChoiceReplacementsLocalizations {
  const MultiChoiceReplacementsLocalizations({
    required this.definition,
    required this.dateTimeReplacements,
  });

  factory MultiChoiceReplacementsLocalizations.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$MultiChoiceReplacementsLocalizationsFromJson(json);

  final Map<String, dynamic> definition;
  final Map<String, String>? dateTimeReplacements;

  String getPlural({
    required String data,
    required Map<String, String> substitutes,
  }) {
    return (definition[data] ?? '')
        .toString()
        .substitute(substitutes.formatDateTime(dateTimeReplacements));
  }
}
