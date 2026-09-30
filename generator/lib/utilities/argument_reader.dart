import 'dart:io';

import 'package:args/args.dart';

/// Lee el argumento [name] de [result] como `String`.
///
/// `ArgResults.operator[]` devuelve `dynamic`, asi que se valida el tipo en
/// tiempo de ejecucion en lugar de hacer un cast.
String readStringArg(ArgResults result, String name) {
  final value = result[name];
  if (value is String) {
    return value;
  }
  throw ArgumentError.value(value, name, 'Expected a string argument');
}

/// Igual que [readStringArg] pero devuelve `null` cuando el argumento no se
/// paso o no es un `String`.
String? readOptionalStringArg(ArgResults result, String name) {
  final value = result[name];
  return value is String ? value : null;
}

/// Convierte un argumento con el formato `palabra:reemplazo,otra:valor` en un
/// mapa de reemplazos globales.
///
/// Los pares vacios o mal formados se descartan silenciosamente y se avisa por
/// pantalla, porque el merge puede seguir adelante sin ellos.
Map<String, String> readReplacementsArg(ArgResults result, String name) {
  final raw = readOptionalStringArg(result, name);
  if (raw == null || raw.isEmpty) {
    return <String, String>{};
  }

  final replacements = <String, String>{};
  for (final pair in raw.split(',')) {
    final parts = pair.split(':');
    if (parts.length == 2) {
      final key = parts.first.trim();
      final value = parts.last.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        replacements[key] = value;
        continue;
      }
    }
    stdout.writeln(
      'Ignoring malformed replacement "$pair", expected the format '
      '"word:replacement"',
    );
  }
  return replacements;
}
