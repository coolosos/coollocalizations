/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  Cool Localization
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

// ignore_for_file: non_constant_identifier_names

library;

import 'package:coollocalizations/coollocalizations.dart';

import "arb_localizations_divisions/login_localization_arb.dart";

part "arb_localizations_merge.g.dart";

abstract interface class ArbLocalizationsMergeMerge {
  const ArbLocalizationsMergeMerge({required this.localizations});

  final List<LanguageLocalizationMerge> localizations;
}

class LanguageLocalizationMerge {
  LanguageLocalizationMerge({required Map<String, dynamic> json})
      : _json = json,
        locale = json['locale'] as String,
        homeWelcomeMessage = MultiChoiceReplacementsLocalizations.fromJson(
          json['homeWelcomeMessage'] as Map<String, dynamic>,
        ),
        landingPackHelpTitle = json['landingPackHelpTitle'] as String,
        helloLoginL10n = json['helloLoginL10n'] as String,
        loginLocalizationArb = LoginLocalizationArb(
          json: json['loginLocalizationArb'] as Map<String, dynamic>,
        );
  final String? locale;
  final MultiChoiceReplacementsLocalizations? homeWelcomeMessage;
  final String? landingPackHelpTitle;
  final String? helloLoginL10n;
  final LoginLocalizationArb? loginLocalizationArb;
  final Map<String, dynamic> _json;
  Map<String, dynamic> get jsonMerge => _json;
  factory LanguageLocalizationMerge.fromJson(Map<String, dynamic> json) {
    return _$LanguageLocalizationMergeFromJson(json);
  }
}
