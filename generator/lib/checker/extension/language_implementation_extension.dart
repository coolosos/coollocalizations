import 'dart:convert';
import 'dart:io';

extension SchemaKey on File {
  Future<List<Map<String, dynamic>>> get getLanguages async {
    final String search = await readAsString();
    final Map<String, dynamic> searchJson = json.decode(search);
    final List<Map<String, dynamic>> languageJson = searchJson['localizations'];
    return languageJson;
  }
}
