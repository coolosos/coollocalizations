import 'package:coollocalizations/coollocalizations.dart';
import 'package:json_annotation/json_annotation.dart';
part 'login_localization_arb.g.dart';
@JsonSerializable()
  final class LoginLocalizationArb{
    const LoginLocalizationArb({
    required this.helloLoginL10n,
required this.multiChoiceL10n,
required this.helloLoginL10n1});


    final String helloLoginL10n;
final MultiChoiceReplacementsLocalizations multiChoiceL10n;
final String helloLoginL10n1;




  factory LoginLocalizationArb.fromJson(Map<String, dynamic> json) {
    return _$LoginLocalizationArbFromJson(json);
  }

  }
