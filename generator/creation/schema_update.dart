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

    var encoder = const JsonEncoder.withIndent("  ");

    schemaFile.writeAsStringSync(encoder.convert(schemaJson));
  }

  Future<void> copySchemaOnLocation({required String copyLocation}) {
    final separatorSplits = copyLocation.split('');
    final newCopyLocation = (separatorSplits.last.contains('/')
            ? separatorSplits
            : ([...separatorSplits, "/"]))
        .join();
    return schemaFile.copy(newCopyLocation + "localization_schema.json");
  }

  Future<File> createMergeSchema({required String path}) async {
    final String schemaString = await schemaFile.readAsString();
    final Map<String, dynamic> schemaJson = json.decode(schemaString);

    schemaJson["required"] = [];

    var encoder = const JsonEncoder.withIndent("  ");

    schemaFile.writeAsStringSync(encoder.convert(schemaJson));

    return schemaFile.copy(path);
  }
}
