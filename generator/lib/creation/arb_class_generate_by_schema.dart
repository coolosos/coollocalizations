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
  new({required this._json});

''';
    final classFields = isForMerge
        ? '''
  Map<String, dynamic> get jsonMerge => _json;

'''
        : '';
    final classGetters = schemas.getters(isForMerge: isForMerge);

    final fromJson =
        '''
  factory fromJson(Map<String, dynamic> json) => $arbLanguageLocalizationsClassName(json:json);

''';

    final fromMergeLocalizations = isForMerge
        ? ''
        : '''
  $arbLanguageLocalizationsClassName updateFromMerge(${arbLanguageLocalizationsClassName}Merge merge){
    return $arbLanguageLocalizationsClassName(
      json: Map<String, dynamic>.of(_json)
        ..updateAll(
          (key, value) => merge.jsonMerge[key] ?? value,
        )
    );
  }

''';

    await writeFileEnsuringDirectory(
      resultFile,
      '$generateCodeExplanation$imports$localizationListObject$classInitialization$fromJson  final Map<String, dynamic> _json;\n\n$classFields$classGetters\n\n$fromMergeLocalizations}\n',
    );

    if (!isForMerge) {
      await schemas.classGeneration(fileNameCases.path, fileNameCases.name);
    }

    print(
      'Code Generated'.colorizeMessage(PrinterStringColor.green, emoji: '✨'),
    );
  }
}

extension SchemasToGetters on List<ArbSchemaCreation> {
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

  /// Genera un getter por propiedad, en lugar de un campo final inicializado en
  /// el constructor. Mantiene el constructor en una sola asignacion, que es lo
  /// que evita que dart2wasm genere una funcion mayor que el limite de WebAssembly.
  String getters({required bool isForMerge}) {
    final nullable = isForMerge ? '?' : '';
    final nullAwareAccess = isForMerge ? '?' : '';

    final members = map((e) {
      final key = e.key;
      final jsonKey = e.key.toLowerCamelCase();
      final value = "_json['$jsonKey']";
      final type = e.dartType(isForMerge: isForMerge);

      String parseWith(String className) => isForMerge
          ? '$value is Map<String, dynamic>\n'
                '    ? $className.fromJson($value as Map<String, dynamic>)\n'
                '    : null'
          : '$className.fromJson($value as Map<String, dynamic>)';

      final body = switch (e) {
        ArbRefCreation() => e.type.resolve(
          onSimple: () => '$value as $type',
          onMultiChoice: () => parseWith('MultiChoiceLocalizations'),
          onMultiChoiceReplacements: () =>
              parseWith('MultiChoiceReplacementsLocalizations'),
          onReplacements: () => parseWith('ReplacementsLocalizations'),
          onReplacementsList: () => parseWith('ReplacementsListLocalizations'),
          onList: () =>
              '($value as List<dynamic>$nullable)$nullAwareAccess.map((e) => e as String).toList()',
        ),
        ArbObjectCreation() =>
          isForMerge
              ? '$value is Map<String, dynamic>\n'
                    '    ? ${e.className}(json: $value as Map<String, dynamic>)\n'
                    '    : null'
              : '${e.className}(json: $value as Map<String, dynamic>)',
      };

      final signature = '$type get $key =>';
      return body.contains('\n')
          ? '$signature\n    $body;'
          : '$signature $body;';
    });

    return members.join('\n\n');
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
  new({required this._json});

  final Map<String, dynamic> _json;

${e.fields.getters(isForMerge: isForMerge)}
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
