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
  new({required this._json});

  factory fromJson(Map<String, dynamic> json) =>
      LanguageLocalizationMerge(json: json);

  final Map<String, dynamic> _json;

  Map<String, dynamic> get jsonMerge => _json;

  String? get locale => _json['locale'] as String?;

  MultiChoiceReplacementsLocalizations? get homeWelcomeMessage =>
      _json['homeWelcomeMessage'] is Map<String, dynamic>
      ? MultiChoiceReplacementsLocalizations.fromJson(
          _json['homeWelcomeMessage'] as Map<String, dynamic>,
        )
      : null;

  String? get landingPackHelpTitle => _json['landingPackHelpTitle'] as String?;

  LoginLocalizationArb? get loginL10n =>
      _json['loginL10n'] is Map<String, dynamic>
      ? LoginLocalizationArb(json: _json['loginL10n'] as Map<String, dynamic>)
      : null;
}
