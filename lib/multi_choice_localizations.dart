import 'package:json_annotation/json_annotation.dart';

part "multi_choice_localizations.g.dart";

@JsonSerializable()
class MultiChoiceLocalizations {
  const MultiChoiceLocalizations({
    required this.definition,
  });

  factory MultiChoiceLocalizations.fromJson(Map<String, dynamic> json) =>
      _$MultiChoiceLocalizationsFromJson(json);

  final Map<String, dynamic> definition;

  String getPlural({required String data}) {
    return (definition[data] ?? definition['other'] ?? definition['default'] ??  '').toString();
  }
}
