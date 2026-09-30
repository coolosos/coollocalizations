import 'dart:io';

import '../../utilities/json_decoder.dart';

extension SchemaLocales on File {
  Future<List<Map<String, dynamic>>> get getLanguages async {
    final errorMessage =
        "File $path it's not an array_localizations json schema";

    final search = await readAsString();
    final List<Object?> languageList;
    try {
      final searchJson = decodeJsonMap(search, context: 'search file');
      languageList = asJsonList(
        searchJson['localizations'],
        context: 'search file localizations',
      );
    } on FormatException catch (error) {
      throw Exception('$errorMessage: $error');
    }

    final languages = languageList.whereType<Map<String, dynamic>>().toList();
    if (languages.length != languageList.length) {
      throw Exception(errorMessage);
    }
    return languages;
  }
}
