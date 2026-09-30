// GENERATED CODE - DO NOT MODIFY BY HAND
// *****************************************************
//  Cool Localization
// *****************************************************

// coverage:ignore-file

import 'package:coollocalizations/coollocalizations.dart';

import 'arb_localizations_divisions/login_localization_arb.dart';

abstract interface class ArbLocalizationsMerge {
  const new({required this.localizations});

  final List<LanguageLocalizationMerge> localizations;
}

class LanguageLocalizationMerge {
  new({required Map<String, dynamic> json})
    : _json = json,
      locale = json['locale'] as String?,
      homeWelcomeMessage = json['homeWelcomeMessage'] is Map<String, dynamic>
          ? MultiChoiceReplacementsLocalizations.fromJson(
              json['homeWelcomeMessage'] as Map<String, dynamic>,
            )
          : null,
      landingPackHelpTitle = json['landingPackHelpTitle'] as String?,
      loginL10n = json['loginL10n'] is Map<String, dynamic>
          ? LoginLocalizationArb(
              json: json['loginL10n'] as Map<String, dynamic>,
            )
          : null;
  factory fromJson(Map<String, dynamic> json) =>
      LanguageLocalizationMerge(json: json);

  final String? locale;
  final MultiChoiceReplacementsLocalizations? homeWelcomeMessage;
  final String? landingPackHelpTitle;
  final LoginLocalizationArb? loginL10n;
  final Map<String, dynamic> _json;
  Map<String, dynamic> get jsonMerge => _json;
}
