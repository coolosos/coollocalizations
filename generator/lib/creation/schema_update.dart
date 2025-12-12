import 'dart:convert';
import 'dart:io';

final class SchemaUpdater {
  const SchemaUpdater({
    required this.schemaFile,
  });

  final File schemaFile;

  Future<void> updateRequirements() async {
    final String schemaString = await schemaFile.readAsString();
    final Map<String, dynamic> schemaJson = json.decode(schemaString);
    final Map<String, dynamic> schemaProperties = schemaJson["properties"];

    final List<String> values = [];

    for (String key in schemaProperties.keys) {
      values.add(key);
    }

    schemaJson["required"] = values;

    _updateSchemaObject(schemaProperties);

    var encoder = const JsonEncoder.withIndent("  ");

    schemaFile.writeAsStringSync(encoder.convert(schemaJson));
  }

  void _updateSchemaObject(
    Map<String, dynamic> schemaProperties, {
    bool isForMergeSchema = false,
  }) {
    final objectSchema = schemaProperties.entries.where(
      (element) {
        if (element.value case final map when map is Map) {
          if (map['properties'] case final properties? when properties is Map) {
            return true;
          }
        }
        return false;
      },
    );

    for (var object in objectSchema) {
      final List<String> internalValues = [];
      if (object.value case final value when value is Map) {
        if (value["properties"] case final valueProperties
            when valueProperties is Map && !isForMergeSchema) {
          for (String key in valueProperties.keys) {
            internalValues.add(key);
          }
        }
        value["type"] = "object";
        value["required"] = internalValues;
        schemaProperties[object.key] = value;
      }
    }
  }

  Future<void> copySchemaOnLocation({required String copyLocation}) {
    final separatorSplits = copyLocation.split('');
    final newCopyLocation = (separatorSplits.last.contains('/')
            ? separatorSplits
            : ([...separatorSplits, "/"]))
        .join();
    return schemaFile.copy("${newCopyLocation}localization_schema.json");
  }

  Future<File> createMergeSchema({required String path}) async {
    final String schemaString = await schemaFile.readAsString();
    final Map<String, dynamic> schemaJson = json.decode(schemaString);
    final Map<String, dynamic> schemaProperties = schemaJson["properties"];

    schemaJson["required"] = [];

    _updateSchemaObject(schemaProperties, isForMergeSchema: true);

    var encoder = const JsonEncoder.withIndent("  ");

    schemaFile.writeAsStringSync(encoder.convert(schemaJson));

    return schemaFile.copy(path);
  }
}
