// GENERATED CODE - DO NOT MODIFY BY HAND
// *****************************************************
//  Cool Localization
// *****************************************************

// coverage:ignore-file

import 'package:coollocalizations/coollocalizations.dart';

import 'arb_localizations_divisions/login_localization_arb.dart';
import 'arb_localizations_merge.dart';

export 'arb_localizations_divisions/login_localization_arb.dart';

abstract interface class ArbLocalizations {
  const new({required this.localizations});

  final List<LanguageLocalization> localizations;
}

class LanguageLocalization {
  new({required this._json});

  factory fromJson(Map<String, dynamic> json) =>
      LanguageLocalization(json: json);

  final Map<String, dynamic> _json;

  String get locale => _json['locale'] as String;

  MultiChoiceReplacementsLocalizations get homeWelcomeMessage =>
      MultiChoiceReplacementsLocalizations.fromJson(
        _json['homeWelcomeMessage'] as Map<String, dynamic>,
      );

  String get landingPackHelpTitle => _json['landingPackHelpTitle'] as String;

  LoginLocalizationArb get loginL10n =>
      LoginLocalizationArb(json: _json['loginL10n'] as Map<String, dynamic>);

  LanguageLocalization updateFromMerge(LanguageLocalizationMerge merge) {
    return LanguageLocalization(
      json: Map<String, dynamic>.of(_json)
        ..updateAll((key, value) => merge.jsonMerge[key] ?? value),
    );
  }
}
