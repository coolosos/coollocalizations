import 'dart:io';

import 'package:collection/collection.dart';

import '../utilities/directory_management.dart';
import '../utilities/json_decoder.dart';
import '../utilities/printer_helper.dart';
import 'utilities/arb_name_case.dart';
import 'utilities/arb_schema_creation.dart';

final class ArbClassGenerateBySchema with PrinterHelper, DirectoryManagement {
  const new({
    required this.schemaFile,
    required this.resultFile,
    required this.isForMerge,
  });

  final File schemaFile;
  final File resultFile;
  final bool isForMerge;

  Future<void> run() async {
    title('Cool Localizations Generator');
    print(
      'Reading json schema'.colorizeMessage(
        PrinterStringColor.yellow,
        emoji: '🔛',
      ),
    );
    final schemaString = await schemaFile.readAsString();
    final schemaJson = decodeJsonMap(schemaString, context: 'schema file');
    final schemaProperties = asJsonMap(
      schemaJson['properties'],
      context: 'schema properties',
    );

    final schemas = <ArbSchemaCreation>[];

    for (final property in schemaProperties.entries) {
      if (ArbSchemaCreation.fromMapEntry(property) case final schema?) {
        schemas.add(schema);
      }
    }

    final fileNameCases = ArbNameCase(file: resultFile);
    print(
      'Generate code'.colorizeMessage(PrinterStringColor.yellow, emoji: '🔛'),
    );
    const generateCodeExplanation = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// *****************************************************
//  Cool Localization
// *****************************************************

// coverage:ignore-file

''';
    final importOfMerge = isForMerge
        ? ''
        : "import '${fileNameCases.name}_merge.dart';";
    final divisionExports = isForMerge
        ? const <String>[]
        : schemas.exportDivisions(fileNameCases.name);
    final directives = <String>[
      ...schemas.importDivisions(fileNameCases.name.replaceFirst('_merge', '')),
      if (importOfMerge.isNotEmpty) importOfMerge,
      if (divisionExports.isNotEmpty) ...['', ...divisionExports],
    ];
    final imports =
        '''
import 'package:coollocalizations/coollocalizations.dart';

${directives.join('\n')}

''';

    final arbLanguageLocalizationsClassName = isForMerge
        ? 'LanguageLocalizationMerge'
        : 'LanguageLocalization';

    final localizationListObject =
        '''
abstract interface class ${fileNameCases.className} {
  const new({required this.localizations});

  final List<$arbLanguageLocalizationsClassName> localizations;
}
''';

    final classInitialization =
        '''
class $arbLanguageLocalizationsClassName {
  new({required Map<String, dynamic> json})''';
    final classRequirements = schemas.requiredFields(isForMerge: isForMerge);
    final classFinals =
        '${schemas.finalFields(isForMerge: isForMerge)}\n${isForMerge ? 'Map<String, dynamic> get jsonMerge => _json;' : ''}';

    final fromJson =
        '''
  factory fromJson(Map<String, dynamic> json) => $arbLanguageLocalizationsClassName(json:json);

''';

    final fromMergeLocalizations = isForMerge
        ? ''
        : '''
  $arbLanguageLocalizationsClassName updateFromMerge(${arbLanguageLocalizationsClassName}Merge merge){
    return $arbLanguageLocalizationsClassName(
      json:_json
        ..updateAll(
          (key, value) => merge.jsonMerge[key] ?? value,
        )
    );
  }

''';

    await writeFileEnsuringDirectory(
      resultFile,
      '$generateCodeExplanation$imports$localizationListObject$classInitialization$classRequirements\n$fromJson$classFinals\n$fromMergeLocalizations}\n',
    );

    if (!isForMerge) {
      await schemas.classGeneration(fileNameCases.path, fileNameCases.name);
    }

    print(
      'Code Generated'.colorizeMessage(PrinterStringColor.green, emoji: '✨'),
    );
  }
}

extension SchemasToFinalFields on List<ArbSchemaCreation> {
  List<String> exportDivisions(
    String fatherName,
  ) => whereType<ArbObjectCreation>()
      .map(
        (e) =>
            """export '${fatherName}_divisions/${e.className.toSnakeCase()}.dart';""",
      )
      .toList()
      .sorted();
  List<String> importDivisions(
    String fatherName,
  ) => whereType<ArbObjectCreation>()
      .map(
        (e) =>
            """import '${fatherName}_divisions/${e.className.toSnakeCase()}.dart';""",
      )
      .toList()
      .sorted();
  String requiredFields({
    required bool isForMerge,
    bool includeJsonField = true,
  }) {
    final instantiations = map((e) {
      return switch (e) {
        ArbRefCreation() => () {
          return e.type.resolve(
            onSimple: () =>
                "${e.key} = json['${e.key.toLowerCamelCase()}'] as ${isForMerge ? 'String?' : 'String'}",
            onMultiChoice: () {
              if (isForMerge) {
                return "${e.key} = json['${e.key.toLowerCamelCase()}'] is Map<String, dynamic> ? MultiChoiceLocalizations.fromJson(json['${e.key.toLowerCamelCase()}'] as Map<String, dynamic>) : null";
              }
              return "${e.key} = MultiChoiceLocalizations.fromJson(json['${e.key.toLowerCamelCase()}'] as Map<String, dynamic>)";
            },
            onMultiChoiceReplacements: () {
              if (isForMerge) {
                return "${e.key} = json['${e.key.toLowerCamelCase()}'] is Map<String, dynamic> ? MultiChoiceReplacementsLocalizations.fromJson(json['${e.key.toLowerCamelCase()}'] as Map<String, dynamic>) : null";
              }
              return "${e.key} = MultiChoiceReplacementsLocalizations.fromJson(json['${e.key.toLowerCamelCase()}'] as Map<String, dynamic>)";
            },
            onReplacements: () {
              if (isForMerge) {
                return "${e.key} = json['${e.key.toLowerCamelCase()}'] is Map<String, dynamic> ? ReplacementsLocalizations.fromJson(json['${e.key.toLowerCamelCase()}'] as Map<String, dynamic>) : null";
              }
              return "${e.key} = ReplacementsLocalizations.fromJson(json['${e.key.toLowerCamelCase()}'] as Map<String, dynamic>)";
            },
            onReplacementsList: () {
              if (isForMerge) {
                return "${e.key} = json['${e.key.toLowerCamelCase()}'] is Map<String, dynamic> ? ReplacementsListLocalizations.fromJson(json['${e.key.toLowerCamelCase()}'] as Map<String, dynamic>) : null";
              }
              return "${e.key} = ReplacementsListLocalizations.fromJson(json['${e.key.toLowerCamelCase()}'] as Map<String, dynamic>)";
            },
            onList: () {
              if (isForMerge) {
                return "${e.key} = (json['${e.key.toLowerCamelCase()}'] as List<dynamic>?)?.map((e) => e as String).toList()";
              }
              return "${e.key} = (json['${e.key.toLowerCamelCase()}'] as List<dynamic>).map((e) => e as String).toList()";
            },
          );
        },
        ArbObjectCreation() => () {
          if (isForMerge) {
            return "${e.key} = json['${e.key.toLowerCamelCase()}'] is Map<String, dynamic> ? ${e.className}(json: json['${e.key.toLowerCamelCase()}'] as Map<String, dynamic>) : null";
          }
          return "${e.key} = ${e.className}(json: json['${e.key.toLowerCamelCase()}'] as Map<String, dynamic>)";
        },
      }();
    }).toList();

    final initializers = <String>[
      if (includeJsonField) '_json = json',
      ...instantiations,
    ];
    return ': ${initializers.join(',\n')};';
  }

  String finalFields({required bool isForMerge, bool includeJsonField = true}) {
    final declarations = map((e) {
      final nullable = isForMerge ? '?' : '';
      return switch (e) {
        ArbRefCreation() =>
          () =>
              'final ${e.type.resolve(onSimple: () => 'String', onMultiChoice: () => 'MultiChoiceLocalizations', onMultiChoiceReplacements: () => 'MultiChoiceReplacementsLocalizations', onReplacements: () => 'ReplacementsLocalizations', onReplacementsList: () => 'ReplacementsListLocalizations', onList: () => 'List<String>')}$nullable ${e.key}',
        ArbObjectCreation() => () => 'final ${e.className}$nullable ${e.key}',
      }();
    }).join(';\n');

    return '$declarations;\n'
        '${includeJsonField ? 'final Map<String, dynamic> _json;' : ''}';
  }

  Future<void> classGeneration(String generatorPath, String fatherName) async {
    final classDir = await directoryCreation(
      '$generatorPath/${fatherName}_divisions',
    );

    await Future.wait(
      whereType<ArbObjectCreation>().map((e) async {
        final className = e.className;

        final fileName =
            '${classDir.path}/${className.toSnakeCase() ?? 'empty'}';
        const isForMerge = false;

        final classContent =
            '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// *****************************************************
//  Cool Localization
// *****************************************************

// coverage:ignore-file

import 'package:coollocalizations/coollocalizations.dart';

final class $className {
  new({required Map<String, dynamic> json})${e.fields.requiredFields(isForMerge: isForMerge, includeJsonField: false)}

  ${e.fields.finalFields(isForMerge: isForMerge, includeJsonField: false).trim()}
}
''';
        final file = File('$fileName.dart');
        await writeFileEnsuringDirectory(file, classContent);
        return file;
      }),
    );
  }

  Future<Directory> directoryCreation(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      return dir;
    }
    await dir.create();
    return dir;
  }
}
