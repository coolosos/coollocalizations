// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replacements_list_localizations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplacementsListLocalizations _$ReplacementsListLocalizationsFromJson(
        Map<String, dynamic> json) =>
    ReplacementsListLocalizations(
      value: (json['value'] as List<dynamic>).map((e) => e as String).toList(),
      dateTimeReplacements:
          (json['dateTimeReplacements'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ReplacementsListLocalizationsToJson(
        ReplacementsListLocalizations instance) =>
    <String, dynamic>{
      'value': instance.value,
      'dateTimeReplacements': instance.dateTimeReplacements,
    };
