import 'dart:convert';

/// Decodifica [source] como un objeto json.
///
/// Lanza [FormatException] con [context] si la carga no es un objeto.
Map<String, dynamic> decodeJsonMap(String source, {required String context}) =>
    asJsonMap(json.decode(source), context: context);

/// Decodifica [source] como un array json.
///
/// Lanza [FormatException] con [context] si la carga no es un array.
List<Object?> decodeJsonList(String source, {required String context}) =>
    asJsonList(json.decode(source), context: context);

/// Convierte [value] en un objeto json validando su tipo en tiempo de ejecucion.
Map<String, dynamic> asJsonMap(Object? value, {required String context}) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException(
    'Expected a json object in $context but found ${value.runtimeType}',
    value,
  );
}

/// Igual que [asJsonMap] pero devuelve un mapa vacio cuando [value] es `null`.
Map<String, dynamic> jsonMapOrEmpty(Object? value, {required String context}) =>
    value == null ? <String, dynamic>{} : asJsonMap(value, context: context);

/// Convierte [value] en un array json validando su tipo en tiempo de ejecucion.
List<Object?> asJsonList(Object? value, {required String context}) {
  if (value is List<Object?>) {
    return value;
  }
  throw FormatException(
    'Expected a json array in $context but found ${value.runtimeType}',
    value,
  );
}

/// Convierte [value] en un `String` validando su tipo en tiempo de ejecucion.
String asJsonString(Object? value, {required String context}) {
  if (value is String) {
    return value;
  }
  throw FormatException(
    'Expected a json string in $context but found ${value.runtimeType}',
    value,
  );
}
