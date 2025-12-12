// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arb_localizations_merge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanguageLocalizationMerge _$LanguageLocalizationMergeFromJson(
        Map<String, dynamic> json) =>
    LanguageLocalizationMerge(
      locale: json['locale'] as String?,
      homeWelcomeMessage: json['homeWelcomeMessage'] == null
          ? null
          : MultiChoiceReplacementsLocalizations.fromJson(
              json['homeWelcomeMessage'] as Map<String, dynamic>),
      landingPackHelpTitle: json['landingPackHelpTitle'] as String?,
      loginLocalizationArb: json['loginLocalizationArb'] == null
          ? null
          : LoginLocalizationArb.fromJson(
              json['loginLocalizationArb'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LanguageLocalizationMergeToJson(
        LanguageLocalizationMerge instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'homeWelcomeMessage': instance.homeWelcomeMessage,
      'landingPackHelpTitle': instance.landingPackHelpTitle,
      'loginLocalizationArb': instance.loginLocalizationArb,
    };
