import 'dart:convert';
import 'dart:io';

import '../utilities/printer_helper.dart';
import 'utilities/arb_object_creation.dart';

final class ArbClassGenerateBySchema with PrinterHelper {
  const ArbClassGenerateBySchema({
    required this.schemaFile,
    required this.resultFile,
    required this.isForMerge,
  });

  final File schemaFile;
  final File resultFile;
  final bool isForMerge;

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

    final generatorPart = isForMerge
        ? "arb_localization_merge.g.dart"
        : "arb_localization.g.dart";
    final importOfMerge =
        isForMerge ? "" : "import 'arb_localization_merge.dart';";
    final imports = """
// ignore_for_file: non_constant_identifier_names

library arb_localization;

import 'package:json_annotation/json_annotation.dart';
import 'package:coollocalizations/coollocalizations.dart';
$importOfMerge

part "$generatorPart";

""";

    final String arbLocalizationsClassName =
        isForMerge ? "ArbLocalizationsMerge" : "ArbLocalizations";

    final String arbLanguageLocalizationsClassName =
        isForMerge ? "LanguageLocalizationMerge" : "LanguageLocalization";

    final localizationListObject = """
abstract interface class $arbLocalizationsClassName {
  const $arbLocalizationsClassName({required this.localizations});

  final List<$arbLanguageLocalizationsClassName> localizations;
}
""";

    final classInitialization = """
@JsonSerializable()
class $arbLanguageLocalizationsClassName {
  const $arbLanguageLocalizationsClassName({
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
                )}${isForMerge ? "?" : ""} ${e.title}")
            .join(";\n") +
        ";\n";

    final creationFunction = """

factory $arbLanguageLocalizationsClassName.fromJson(Map<String, dynamic> json) {
    return _\$${arbLanguageLocalizationsClassName}FromJson(json);
  }
  """;

    String fromMergeLocalizations = isForMerge
        ? ""
        : """

$arbLanguageLocalizationsClassName updateFromMerge(${arbLanguageLocalizationsClassName}Merge merge){
  return ${arbLanguageLocalizationsClassName}(
      ${arbObjectsCreation.map((e) => "${e.title} : merge.${e.title} ?? ${e.title}").join(",\n")}
  );
}

""";

    resultFile.writeAsStringSync(
      generateCodeExplanation +
          imports +
          localizationListObject +
          classInitialization +
          classRequirements +
          classFinals +
          creationFunction +
          fromMergeLocalizations +
          "\n" +
          "}",
    );

    print(
        "Code Generated".colorizeMessage(PrinterStringColor.green, emoji: "✨"));
  }
}
