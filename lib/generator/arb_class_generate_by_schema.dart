import 'dart:convert';
import 'dart:io';

import 'utilities/arb_object_creation.dart';

final class ArbClassGenerateBySchema {
  const ArbClassGenerateBySchema({
    required this.schemaFile,
    required this.resultFile,
  });

  final File schemaFile;
  final File resultFile;

  Future<void> run() async {
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
    final imports = """
// ignore_for_file: non_constant_identifier_names

library arb_localization;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:coollocalizations/coollocalizations.dart'

""";

    final classInitializator = """
@JsonSerializable()
class ArbLocalizations {
  const ArbLocalizations({
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
factory ArbLocalizations.fromFile(String file) {
    return _\$ArbLocalizationsFromJson(json.decode(file));
  }
  """;
    resultFile.writeAsStringSync(
      imports +
          classInitializator +
          classRequirements +
          classFinals +
          creationFunction +
          "\n" +
          "}",
    );
  }
}