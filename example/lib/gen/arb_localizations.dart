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
  new({required Map<String, dynamic> json})
    : _json = json,
      locale = json['locale'] as String,
      homeWelcomeMessage = MultiChoiceReplacementsLocalizations.fromJson(
        json['homeWelcomeMessage'] as Map<String, dynamic>,
      ),
      landingPackHelpTitle = json['landingPackHelpTitle'] as String,
      loginL10n = LoginLocalizationArb(
        json: json['loginL10n'] as Map<String, dynamic>,
      );
  factory fromJson(Map<String, dynamic> json) =>
      LanguageLocalization(json: json);

  final String locale;
  final MultiChoiceReplacementsLocalizations homeWelcomeMessage;
  final String landingPackHelpTitle;
  final LoginLocalizationArb loginL10n;
  final Map<String, dynamic> _json;

  LanguageLocalization updateFromMerge(LanguageLocalizationMerge merge) {
    return LanguageLocalization(
      json: _json..updateAll((key, value) => merge.jsonMerge[key] ?? value),
    );
  }
}
