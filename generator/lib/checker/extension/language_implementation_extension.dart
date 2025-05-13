import 'dart:convert';
import 'dart:io';

extension SchemaKey on File {
  Future<List<Map<String, dynamic>>> get getLanguages async {
    try {
      final String search = await readAsString();
      final Map<String, dynamic> searchJson = json.decode(search);
      final List<Map<String, dynamic>> languageJson =
          searchJson['localizations'];
      return languageJson;
    } catch (e) {
      final String search = await readAsString();
      final Map<String, dynamic> searchJson = json.decode(search);
      throw Exception(
        "File it's not as example_array_localizations in json_schema\n${searchJson['localizations'].runtimeType}",
      );
    }
  }
}
