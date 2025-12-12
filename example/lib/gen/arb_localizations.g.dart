// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arb_localizations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanguageLocalization _$LanguageLocalizationFromJson(
        Map<String, dynamic> json) =>
    LanguageLocalization(
      locale: json['locale'] as String,
      homeWelcomeMessage: MultiChoiceReplacementsLocalizations.fromJson(
          json['homeWelcomeMessage'] as Map<String, dynamic>),
      landingPackHelpTitle: json['landingPackHelpTitle'] as String,
      loginLocalizationArb: LoginLocalizationArb.fromJson(
          json['loginLocalizationArb'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LanguageLocalizationToJson(
        LanguageLocalization instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'homeWelcomeMessage': instance.homeWelcomeMessage,
      'landingPackHelpTitle': instance.landingPackHelpTitle,
      'loginLocalizationArb': instance.loginLocalizationArb,
    };
