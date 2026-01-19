import 'package:coollocalizations/coollocalizations.dart';

final class LoginLocalizationArb {
  LoginLocalizationArb({required Map<String, dynamic> json})
      : helloLoginL10n = json['helloLoginL10n'] as String,
        multiChoiceL10n = MultiChoiceReplacementsLocalizations.fromJson(
          json['multiChoiceL10n'] as Map<String, dynamic>,
        ),
        helloLoginL10n1 = json['helloLoginL10n1'] as String;

  final String helloLoginL10n;
  final MultiChoiceReplacementsLocalizations multiChoiceL10n;
  final String helloLoginL10n1;
}
