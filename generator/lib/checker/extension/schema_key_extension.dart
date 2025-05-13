import 'dart:convert';
import 'dart:io';

extension SchemaKey on File {
  Future<Set<String>> get getSchemaKeysFromProperties async {
    final String schema = await readAsString();
    final Map<String, dynamic> schemaJson = json.decode(schema);
    return (schemaJson['properties'] as Map<String, dynamic>).keys.toSet()
      ..removeWhere((key) => key.contains('@'));
  }
}
