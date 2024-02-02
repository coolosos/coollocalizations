// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_choice_replacements_localizations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiChoiceReplacementsLocalizations
    _$MultiChoiceReplacementsLocalizationsFromJson(Map<String, dynamic> json) =>
        MultiChoiceReplacementsLocalizations(
          definition: json['definition'] as Map<String, dynamic>,
          dateTimeReplacements:
              (json['dateTimeReplacements'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ),
        );

Map<String, dynamic> _$MultiChoiceReplacementsLocalizationsToJson(
        MultiChoiceReplacementsLocalizations instance) =>
    <String, dynamic>{
      'definition': instance.definition,
      'dateTimeReplacements': instance.dateTimeReplacements,
    };
