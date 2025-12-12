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


import "arb_localizations_divisions/login_localization_arb.dart";

part "arb_localizations_merge.g.dart";


abstract interface class ArbLocalizationsMergeMerge {
  const ArbLocalizationsMergeMerge({required this.localizations});

  final List<LanguageLocalizationMerge> localizations;
}
@JsonSerializable()
class LanguageLocalizationMerge {
  const LanguageLocalizationMerge({
required this.locale,
required this.homeWelcomeMessage,
required this.landingPackHelpTitle,
required this.loginLocalizationArb});

final String? locale;
final MultiChoiceReplacementsLocalizations? homeWelcomeMessage;
final String? landingPackHelpTitle;
final LoginLocalizationArb? loginLocalizationArb;

factory LanguageLocalizationMerge.fromJson(Map<String, dynamic> json) {
    return _$LanguageLocalizationMergeFromJson(json);
  }
  
}