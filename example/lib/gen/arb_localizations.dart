/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  Cool Localization
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

// ignore_for_file: non_constant_identifier_names

library;

import 'package:json_annotation/json_annotation.dart';
import 'package:coollocalizations/coollocalizations.dart';
import 'arb_localizations_merge.dart';

import "arb_localizations_divisions/login_localization_arb.dart";
export "arb_localizations_divisions/login_localization_arb.dart";
part "arb_localizations.g.dart";


abstract interface class ArbLocalizations {
  const ArbLocalizations({required this.localizations});

  final List<LanguageLocalization> localizations;
}
@JsonSerializable()
class LanguageLocalization {
  const LanguageLocalization({
required this.locale,
required this.homeWelcomeMessage,
required this.landingPackHelpTitle,
required this.loginLocalizationArb});

final String locale;
final MultiChoiceReplacementsLocalizations homeWelcomeMessage;
final String landingPackHelpTitle;
final LoginLocalizationArb loginLocalizationArb;

factory LanguageLocalization.fromJson(Map<String, dynamic> json) {
    return _$LanguageLocalizationFromJson(json);
  }
  
LanguageLocalization updateFromMerge(LanguageLocalizationMerge merge){
  return LanguageLocalization(
      locale : merge.locale ?? locale,
homeWelcomeMessage : merge.homeWelcomeMessage ?? homeWelcomeMessage,
landingPackHelpTitle : merge.landingPackHelpTitle ?? landingPackHelpTitle,
loginLocalizationArb : merge.loginLocalizationArb ?? loginLocalizationArb
  );
}


}