import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../utilities/json_decoder.dart';

final class SchemaUpdater {
  const new({required this.schemaFile});

  final File schemaFile;

  Future<void> updateRequirements() async {
    final schemaString = await schemaFile.readAsString();
    final schemaJson = decodeJsonMap(schemaString, context: 'schema file');
    final schemaProperties = asJsonMap(
      schemaJson['properties'],
      context: 'schema properties',
    );

    schemaJson['required'] = schemaProperties.keys.toList();

    _updateSchemaObject(schemaProperties);

    const encoder = JsonEncoder.withIndent('  ');

    schemaFile.writeAsStringSync(encoder.convert(schemaJson));
  }

  void _updateSchemaObject(
    Map<String, dynamic> schemaProperties, {
    bool isForMergeSchema = false,
  }) {
    final objectSchema = schemaProperties.entries.where(
      (element) => element.value is Map<String, dynamic>,
    );

    for (final object in objectSchema) {
      final objectValue = object.value;
      if (objectValue is Map<String, dynamic>) {
        final properties = objectValue['properties'];
        if (properties is Map<String, dynamic>) {
          objectValue['type'] = 'object';
          objectValue['required'] = isForMergeSchema
              ? <String>[]
              : properties.keys.toList();
          schemaProperties[object.key] = objectValue;
        }
      }
    }
  }

  /// Copia el schema en [copyLocation] con el nombre `localization_schema.json`.
  ///
  /// [copyLocation] se interpreta como un directorio, tanto si termina en
  /// separador como si no, y en cualquier plataforma. El directorio se crea
  /// si no existe.
  Future<void> copySchemaOnLocation({required String copyLocation}) async {
    final directory = Directory(copyLocation);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    await schemaFile.copy(p.join(copyLocation, 'localization_schema.json'));
  }

  Future<File> createMergeSchema({required String path}) async {
    final schemaString = await schemaFile.readAsString();
    final schemaJson = decodeJsonMap(schemaString, context: 'schema file');
    final schemaProperties = asJsonMap(
      schemaJson['properties'],
      context: 'schema properties',
    );

    schemaJson['required'] = <String>[];

    _updateSchemaObject(schemaProperties, isForMergeSchema: true);

    const encoder = JsonEncoder.withIndent('  ');

    schemaFile.writeAsStringSync(encoder.convert(schemaJson));

    final destinationDirectory = Directory(p.dirname(path));
    if (!await destinationDirectory.exists()) {
      await destinationDirectory.create(recursive: true);
    }

    final copy = await schemaFile.copy(path);
    return copy;
  }
}
