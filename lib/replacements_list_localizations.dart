import 'extension/replace_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part "replacements_list_localizations.g.dart";

@JsonSerializable()
class ReplacementsListLocalizations {
  const ReplacementsListLocalizations({
    required this.value,
    required this.dateTimeReplacements,
  });

  factory ReplacementsListLocalizations.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ReplacementsListLocalizationsFromJson(json);

  final List<String> value;
  final Map<String, String>? dateTimeReplacements;

  List<String> run(
    Map<String, dynamic> substitutesWords, {
    required String? locale,
  }) {
    return [
      for (var i = 0; i < value.length; i++)
        value[i].substitute(
          substitutesWords.formatDateTime(
            dateTimeReplacements,
            locale: locale,
          ),
        ),
    ];
  }
}
