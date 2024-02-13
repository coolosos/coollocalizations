import 'dart:convert';
import 'dart:io';

import '../utilities/printer_helper.dart';
import 'utilities/arb_object_creation.dart';

final class ArbClassGenerateBySchema with PrinterHelper {
  const ArbClassGenerateBySchema({
    required this.schemaFile,
    required this.resultFile,
  });

  final File schemaFile;
  final File resultFile;

  Future<void> run() async {
    title("Cool Localizations Generator");
    print("Reading json schema"
        .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"));
    final String schemaString = await schemaFile.readAsString();
    final Map<String, dynamic> schemaJson = json.decode(schemaString);
    final Map<String, dynamic> schemaProperties = schemaJson["properties"];

    final List<ArbObjectCreation> arbObjectsCreation = [];

    for (MapEntry<String, dynamic> property in schemaProperties.entries) {
      arbObjectsCreation.add(
        ArbObjectCreation.fromMap(
          <String, dynamic>{property.key: property.value},
        ),
      );
    }
    print("Generate code"
        .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"));
    final generateCodeExplanation = """
/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  Cool Localization
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

""";
    final imports = """
// ignore_for_file: non_constant_identifier_names

library arb_localization;

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:coollocalizations/coollocalizations.dart';


part "arb_localization.g.dart";

""";

    final localizationListObject = """
abstract interface class ArbLocalizations {
  const ArbLocalizations({required this.localizations});

  final List<LanguajeLocalization> localizations;
}
""";

    final classInitializator = """
@JsonSerializable()
class LanguajeLocalization {
  const LanguajeLocalization({
""";
    final classRequirements =
        arbObjectsCreation.map((e) => "required this.${e.title}").join(",\n") +
            "});";
    final classFinals = arbObjectsCreation
            .map((e) => "final ${e.type.resolve(
                  onSimple: () => "String",
                  onMultiChoice: () => "MultiChoiceLocalizations",
                  onMultiChoiceReplacements: () =>
                      "MultiChoiceReplacementsLocalizations",
                  onReplacements: () => "ReplacementsLocalizations",
                )} ${e.title}")
            .join(";\n") +
        ";\n";

    final creationFunction = """
factory LanguajeLocalization.FromJson(String file) {
    return _\$LanguajeLocalizationFromJson(json.decode(file));
  }
  """;

    resultFile.writeAsStringSync(
      generateCodeExplanation +
          imports +
          localizationListObject +
          classInitializator +
          classRequirements +
          classFinals +
          creationFunction +
          "\n" +
          "}",
    );

    print(
        "Code Generated".colorizeMessage(PrinterStringColor.green, emoji: "✨"));
  }
}
