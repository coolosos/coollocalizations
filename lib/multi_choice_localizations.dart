import 'package:coollocalizations/extension/replace_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part "multi_choice_localizations.g.dart";

@JsonSerializable()
class MultiChoiceLocalizations {
  const MultiChoiceLocalizations({
    required this.definition,
    required this.replaceKey,
  });

  factory MultiChoiceLocalizations.fromJson(Map<String, dynamic> json) =>
      _$MultiChoiceLocalizationsFromJson(json);

  final Map<String, dynamic> definition;
  final String? replaceKey;

  String getPlural({required String data}) {
    return (definition[data] ?? '')
        .toString()
        .substitute({(replaceKey ?? ''): data});
  }
}
