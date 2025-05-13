import 'dart:convert';
import 'dart:io';

extension SchemaKey on File {
  Future<List<Map<String, dynamic>>> get getLanguages async {
    try {
      final String search = await readAsString();
      final Map<String, dynamic> searchJson = json.decode(search);
      final List<dynamic> languageList = searchJson['localizations'];
      final List<Map<String, dynamic>> languageJson = [];

      if (languageList.every(
        (element) => element is Map<String, dynamic>,
      )) {
        return languageJson.cast<Map<String, dynamic>>();
      }
      throw Exception();
    } catch (e) {
      final String search = await readAsString();
      final Map<String, dynamic> searchJson = json.decode(search);
      throw Exception(
        "File it's not as example_array_localizations in json_schema\n${(searchJson['localizations'] as List<dynamic>).every(
          (element) => element is Map<String, dynamic>,
        )}",
      );
    }
  }
}
