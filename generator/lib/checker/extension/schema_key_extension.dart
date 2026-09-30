import 'dart:io';

import '../../utilities/json_decoder.dart';

extension SchemaKeys on File {
  Future<Set<String>> get getSchemaKeysFromProperties async {
    final schema = await readAsString();
    try {
      final schemaJson = decodeJsonMap(schema, context: 'arb schema file');
      final properties = asJsonMap(
        schemaJson['properties'],
        context: 'arb schema properties',
      );
      return properties.keys.toSet()..removeWhere((key) => key.contains('@'));
    } on FormatException catch (error) {
      throw Exception(
        "File $path it's not an arb_localization json schema: $error",
      );
    }
  }
}
