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
import 'arb_localizations_merge.dart';

import "arb_localizations_divisions/login_localization_arb.dart";
export "arb_localizations_divisions/login_localization_arb.dart";

abstract interface class ArbLocalizations {
  const ArbLocalizations({required this.localizations});

  final List<LanguageLocalization> localizations;
}

class LanguageLocalization {
  LanguageLocalization({required Map<String, dynamic> json})
      : _json = json,
        locale = json['locale'] as String,
        homeWelcomeMessage = MultiChoiceReplacementsLocalizations.fromJson(
          json['homeWelcomeMessage'] as Map<String, dynamic>,
        ),
        landingPackHelpTitle = json['landingPackHelpTitle'] as String,
        loginLocalizationArb = LoginLocalizationArb(
          json: json['loginLocalizationArb'] as Map<String, dynamic>,
        );
  final String locale;
  final MultiChoiceReplacementsLocalizations homeWelcomeMessage;
  final String landingPackHelpTitle;
  final LoginLocalizationArb loginLocalizationArb;
  final Map<String, dynamic> _json;
  LanguageLocalization updateFromMerge(LanguageLocalizationMerge merge) {
    return LanguageLocalization(
        json: _json
          ..updateAll(
            (key, value) => merge.jsonMerge[key],
          ));
  }
}
