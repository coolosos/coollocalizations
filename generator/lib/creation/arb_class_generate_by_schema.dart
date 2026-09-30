import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../utilities/directory_management.dart';
import '../utilities/json_decoder.dart';
import '../utilities/printer_helper.dart';
import 'utilities/arb_name_case.dart';
import 'utilities/arb_schema_creation.dart';

/// Cabecera comun a todos los ficheros generados.
const _fileHeader = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// *****************************************************
//  Cool Localization
// *****************************************************

// coverage:ignore-file
''';

/// Construye [className] desde el mapa anidado en [entry] con su factory
/// `fromJson`. En merge la clave puede no venir en el arb, asi que el valor
/// solo se construye cuando el mapa esta presente.
String _fromJsonOf(String className, String entry, bool isForMerge) =>
    isForMerge
    ? '$entry is Map<String, dynamic>\n'
          '    ? $className.fromJson($entry as Map<String, dynamic>)\n'
          '    : null'
    : '$className.fromJson($entry as Map<String, dynamic>)';

/// Igual que [_fromJsonOf] pero para las divisiones, cuyo constructor recibe el
/// mapa en un parametro `json` en lugar de exponer un `fromJson`.
String _divisionOf(String className, String entry, bool isForMerge) =>
    isForMerge
    ? '$entry is Map<String, dynamic>\n'
          '    ? $className(json: $entry as Map<String, dynamic>)\n'
          '    : null'
    : '$className(json: $entry as Map<String, dynamic>)';

final class ArbClassGenerateBySchema with PrinterHelper, DirectoryManagement {
  const new({
    required this.schemaFile,
    required this.resultFile,
    required this.isForMerge,
  });

  final File schemaFile;
  final File resultFile;
  final bool isForMerge;

  /// Nombre de la clase que agrupa las localizaciones del arb.
  String get _localizationClassName =>
      isForMerge ? 'LanguageLocalizationMerge' : 'LanguageLocalization';

  Future<void> run() async {
    title('Cool Localizations Generator');
    print(
      'Reading json schema'.colorizeMessage(
        PrinterStringColor.yellow,
        emoji: '🔛',
      ),
    );
    final schemaString = await schemaFile.readAsString();
    final schemas = _parseSchemas(
      decodeJsonMap(schemaString, context: 'schema file'),
    );

    final fileNameCases = ArbNameCase(file: resultFile);
    print(
      'Generate code'.colorizeMessage(PrinterStringColor.yellow, emoji: '🔛'),
    );

    await writeFileEnsuringDirectory(
      resultFile,
      _localizationFile(fileNameCases, schemas),
    );
    if (!isForMerge) {
      await _writeDivisions(fileNameCases, schemas);
    }

    print(
      'Code Generated'.colorizeMessage(PrinterStringColor.green, emoji: '✨'),
    );
  }

  List<ArbSchemaCreation> _parseSchemas(Map<String, dynamic> schemaJson) {
    final properties = asJsonMap(
      schemaJson['properties'],
      context: 'schema properties',
    );
    return properties.entries
        .map(ArbSchemaCreation.fromMapEntry)
        .nonNulls
        .toList();
  }

  /// Contenido del fichero con la clase de localizaciones y su interfaz.
  String _localizationFile(
    ArbNameCase fileNameCases,
    List<ArbSchemaCreation> schemas,
  ) {
    final className = _localizationClassName;

    return [
      _fileHeader,
      '\n',
      _imports(fileNameCases, schemas),
      '\n',
      '''
abstract interface class ${fileNameCases.className} {
  const new({required this.localizations});

  final List<$className> localizations;
}
''',
      '\n',
      '''
class $className {
  new({required this._json});
''',
      '\n',
      '''
  factory fromJson(Map<String, dynamic> json) => $className(json:json);
''',
      '\n',
      '  final Map<String, dynamic> _json;\n',
      '\n',
      if (isForMerge) '  Map<String, dynamic> get jsonMerge => _json;\n',
      if (isForMerge) '\n',
      '${schemas.getters(isForMerge: isForMerge)}\n',
      if (!isForMerge) ...[
        '\n',
        '''
  $className updateFromMerge(${className}Merge merge) {
    return $className(
      json: Map<String, dynamic>.of(_json)
        ..updateAll(
          (key, value) => merge.jsonMerge[key] ?? value,
        )
    );
  }
''',
      ],
      '}\n',
    ].join();
  }

  /// Bloque de imports y exports, con una linea en blanco entre cada grupo.
  String _imports(ArbNameCase fileNameCases, List<ArbSchemaCreation> schemas) {
    final divisions = schemas.importDivisions(
      fileNameCases.name.replaceFirst('_merge', ''),
    );
    final mergeImport = isForMerge
        ? null
        : "import '${fileNameCases.name}_merge.dart';";
    final divisionExports = isForMerge
        ? const <String>[]
        : schemas.exportDivisions(fileNameCases.name);

    return [
      "import 'package:coollocalizations/coollocalizations.dart';",
      '',
      ...divisions,
      ?mergeImport,
      if (divisionExports.isNotEmpty) ...['', ...divisionExports],
      '',
    ].join('\n');
  }

  /// Escribe una clase por cada division del schema.
  Future<void> _writeDivisions(
    ArbNameCase fileNameCases,
    List<ArbSchemaCreation> schemas,
  ) async {
    await Future.wait(
      schemas.whereType<ArbObjectCreation>().map((division) {
        final file = File(
          p.join(
            fileNameCases.path,
            '${fileNameCases.name}_divisions',
            '${division.className.toSnakeCase()}.dart',
          ),
        );

        return writeFileEnsuringDirectory(
          file,
          [
            _fileHeader,
            '\n',
            "import 'package:coollocalizations/coollocalizations.dart';\n",
            '\n',
            'final class ${division.className} {\n',
            '  new({required this._json});\n',
            '\n',
            '  final Map<String, dynamic> _json;\n',
            '\n',
            '${division.fields.getters(isForMerge: false)}\n',
            '}\n',
          ].join(),
        );
      }),
    );
  }
}

extension SchemasToDart on List<ArbSchemaCreation> {
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

  /// Emite un getter por propiedad en lugar de un campo final inicializado en el
  /// constructor. Dejar el constructor en una sola asignacion es lo que evita
  /// que dart2wasm compile la inicializacion en una funcion mayor que el limite
  /// de tamano por funcion de WebAssembly.
  String getters({required bool isForMerge}) {
    final members = map((schema) {
      final name = schema.key;
      final entry = "_json['${schema.key.toLowerCamelCase()}']";
      final type = schema.dartType(isForMerge: isForMerge);

      final body = switch (schema) {
        ArbRefCreation() => switch (schema.type) {
          ArbObjectType.simple => '$entry as $type',
          ArbObjectType.multiChoice => _fromJsonOf(
            'MultiChoiceLocalizations',
            entry,
            isForMerge,
          ),
          ArbObjectType.multiChoiceReplacements => _fromJsonOf(
            'MultiChoiceReplacementsLocalizations',
            entry,
            isForMerge,
          ),
          ArbObjectType.replacements => _fromJsonOf(
            'ReplacementsLocalizations',
            entry,
            isForMerge,
          ),
          ArbObjectType.replacementsList => _fromJsonOf(
            'ReplacementsListLocalizations',
            entry,
            isForMerge,
          ),
          ArbObjectType.list =>
            isForMerge
                ? '($entry as List<dynamic>?)?.map((e) => e as String).toList()'
                : '($entry as List<dynamic>).map((e) => e as String).toList()',
        },
        ArbObjectCreation() => _divisionOf(schema.className, entry, isForMerge),
      };

      // Los cuerpos con ternario, que solo aparecen en merge, se emiten
      // partidos en lineas para no depender de un dart format posterior.
      return body.contains('\n')
          ? '$type get $name =>\n    $body;'
          : '$type get $name => $body;';
    });

    return members.join('\n\n');
  }
}
