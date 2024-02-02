// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replacements_localizations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplacementsLocalizations _$ReplacementsLocalizationsFromJson(
        Map<String, dynamic> json) =>
    ReplacementsLocalizations(
      value: json['value'] as String,
      dateTimeReplacements:
          (json['dateTimeReplacements'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ReplacementsLocalizationsToJson(
        ReplacementsLocalizations instance) =>
    <String, dynamic>{
      'value': instance.value,
      'dateTimeReplacements': instance.dateTimeReplacements,
    };
