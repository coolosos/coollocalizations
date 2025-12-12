import 'dart:convert';
import 'dart:io';

import '../utilities/printer_helper.dart';
import 'utilities/arb_name_case.dart';
import 'utilities/arb_schema_creation.dart';

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
    print(
      "Reading json schema"
          .colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"),
    );
    final String schemaString = await schemaFile.readAsString();
    final Map<String, dynamic> schemaJson = json.decode(schemaString);
    final Map<String, dynamic> schemaProperties = schemaJson["properties"];

    final List<ArbSchemaCreation> schemas = [];

    for (MapEntry<String, dynamic> property in schemaProperties.entries) {
      if (ArbSchemaCreation.fromMapEntry(property) case final schema?) {
        schemas.add(
          schema,
        );
      }
    }

    final ArbNameCase fileNameCases = ArbNameCase(file: resultFile);
    print(
      "Generate code".colorizeMessage(PrinterStringColor.yellow, emoji: "🔛"),
    );
    const generateCodeExplanation = """
/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  Cool Localization
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

""";

    final generatorPart = "${fileNameCases.name}.g.dart";
    final importOfMerge =
        isForMerge ? "" : "import '${fileNameCases.name}_merge.dart';";
    final imports = """
// ignore_for_file: non_constant_identifier_names

library;

import 'package:json_annotation/json_annotation.dart';
import 'package:coollocalizations/coollocalizations.dart';
$importOfMerge

${schemas.importDivisions(
      fileNameCases.name.replaceFirst('_merge', ''),
    )}
${isForMerge ? '' : schemas.exportDivisions(
            fileNameCases.name,
          )}
part "$generatorPart";


""";

    final String arbLocalizationsClassName = isForMerge
        ? "${fileNameCases.className}Merge"
        : fileNameCases.className;

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
    final classRequirements = schemas.requiredFields();
    final classFinals = schemas.finalFields(isForMerge: isForMerge);

    final creationFunction = """

factory $arbLanguageLocalizationsClassName.fromJson(Map<String, dynamic> json) {
    return _\$${arbLanguageLocalizationsClassName}FromJson(json);
  }
  """;

    String fromMergeLocalizations = isForMerge
        ? ""
        : """

$arbLanguageLocalizationsClassName updateFromMerge(${arbLanguageLocalizationsClassName}Merge merge){
  return $arbLanguageLocalizationsClassName(
      ${schemas.mergeFields()}
  );
}

""";

    resultFile.writeAsStringSync(
      "$generateCodeExplanation$imports$localizationListObject$classInitialization$classRequirements$classFinals$creationFunction$fromMergeLocalizations\n}",
    );

    if (!isForMerge) {
      await schemas.classGeneration(
        fileNameCases.path,
        fileNameCases.name,
      );
    }

    print(
      "Code Generated".colorizeMessage(PrinterStringColor.green, emoji: "✨"),
    );
  }
}

extension SchemasToFinalFields on List<ArbSchemaCreation> {
  String exportDivisions(String fatherName) => whereType<ArbObjectCreation>()
      .map(
        (e) =>
            """export "${fatherName}_divisions/${e.title.toSnakeCase()}.dart";""",
      )
      .join('\n');
  String importDivisions(String fatherName) => whereType<ArbObjectCreation>()
      .map(
        (e) =>
            """import "${fatherName}_divisions/${e.title.toSnakeCase()}.dart";""",
      )
      .join('\n');
  String requiredFields() =>
      "${map((e) => "required this.${e.title.toLowerCamelCase()}").join(",\n")}});\n\n";

  String finalFields({required bool isForMerge}) {
    return "${map(
      (e) {
        return switch (e) {
          ArbRefCreation() => () => "final ${e.type.resolve(
                onSimple: () => "String",
                onMultiChoice: () => "MultiChoiceLocalizations",
                onMultiChoiceReplacements: () =>
                    "MultiChoiceReplacementsLocalizations",
                onReplacements: () => "ReplacementsLocalizations",
                onReplacementsList: () => 'ReplacementsListLocalizations',
                onList: () => 'List<String>',
              )}${isForMerge ? "?" : ""} ${e.title}",
          ArbObjectCreation() => () =>
              "final ${e.title}${isForMerge ? "?" : ""} ${e.title.toLowerCamelCase()}",
        }();
      },
    ).join(";\n")};\n";
  }

  String mergeFields() => map(
        (e) =>
            "${e.title.toLowerCamelCase()} : merge.${e.title.toLowerCamelCase()} ?? ${e.title.toLowerCamelCase()}",
      ).join(",\n");

  Future<void> classGeneration(String generatorPath, String fatherName) async {
    final classDir =
        await directoryCreation('$generatorPath/${fatherName}_divisions');

    await Future.wait(
      whereType<ArbObjectCreation>().map(
        (e) async {
          final title = e.title;

          final fileName =
              "${classDir.path}/${(title.toSnakeCase() ?? 'empty')}";

          final classContent = """
import 'package:coollocalizations/coollocalizations.dart';
import 'package:json_annotation/json_annotation.dart';
part '${(title.toSnakeCase() ?? 'empty')}.g.dart';
@JsonSerializable()
  final class $title{
    const $title({
    ${e.fields.requiredFields()}
    ${e.fields.finalFields(isForMerge: false)}



  factory $title.fromJson(Map<String, dynamic> json) {
    return _\$${title}FromJson(json);
  }

  }
""";
          final file = File("$fileName.dart");
          await file.writeAsString(classContent);
          return file;
        },
      ),
    );
  }

  Future<Directory> directoryCreation(String path) async {
    final Directory dir = Directory(path);
    final bool dirExist = await dir.exists();

    if (dirExist) {
      return dir;
    }
    try {
      await dir.create();
      return dir;
    } catch (e) {
      rethrow;
    }
  }
}
