import '../../utilities/json_decoder.dart';

/// Añade el sufijo `?` que llevan los tipos de la variante de merge.
String _nullableType(String type, bool isForMerge) =>
    isForMerge ? '$type?' : type;

enum ArbObjectType {
  simple,
  multiChoice,
  multiChoiceReplacements,
  replacements,
  replacementsList,
  list;

  static ArbObjectType? fromString(Object? preType) {
    if (preType is! String || preType.isEmpty) {
      return null;
    }
    if (preType.contains('multiChoiceReplacements')) {
      return multiChoiceReplacements;
    }
    if (preType.contains('multiChoice')) {
      return multiChoice;
    }
    if (preType.contains('replacementList')) {
      return replacementsList;
    }
    if (preType.contains('simpleList')) {
      return list;
    }
    if (preType.contains('replacement')) {
      return replacements;
    }
    return simple;
  }

  /// Tipo Dart al que apunta una referencia de este tipo, sin nullabilidad.
  String get dartTypeName => switch (this) {
    ArbObjectType.simple => 'String',
    ArbObjectType.multiChoice => 'MultiChoiceLocalizations',
    ArbObjectType.multiChoiceReplacements =>
      'MultiChoiceReplacementsLocalizations',
    ArbObjectType.replacements => 'ReplacementsLocalizations',
    ArbObjectType.replacementsList => 'ReplacementsListLocalizations',
    ArbObjectType.list => 'List<String>',
  };
}

final class ArbRefCreation extends ArbSchemaCreation {
  const new({required super.key, required this.type});

  /// Tipo al que apunta la propiedad del schema.
  final ArbObjectType type;

  @override
  String dartType({required bool isForMerge}) =>
      _nullableType(type.dartTypeName, isForMerge);
}

final class ArbObjectCreation extends ArbSchemaCreation {
  const new({
    required super.key,
    required this.className,
    required this.fields,
  });

  /// Nombre de la clase Dart generada, tomado del `name` del schema.
  final String className;

  /// Propiedades del objeto, que se emiten en su propia clase de división.
  final List<ArbSchemaCreation> fields;

  @override
  String dartType({required bool isForMerge}) =>
      _nullableType(className, isForMerge);
}

sealed class ArbSchemaCreation {
  const new({required this.key});

  /// Tipo con el que se declara la propiedad en la clase generada.
  String dartType({required bool isForMerge});

  /// Parsea una única entrada de propiedades del schema.
  ///
  /// Lanza [FormatException] si la entrada no es soportada.
  static ArbSchemaCreation fromMapEntry(MapEntry<String, dynamic> entry) {
    final valueMap = asJsonMap(
      entry.value,
      context: 'schema property ${entry.key}',
    );
    final type = ArbObjectType.fromString(valueMap[r'$ref']);
    if (type != null) {
      return ArbRefCreation(key: entry.key, type: type);
    }

    final properties = valueMap['properties'];
    final className = valueMap['name'];
    if (properties is Map<String, dynamic> && className is String) {
      final fields = ArbSchemaCreation.fromMapEntries(
        properties.entries.toList(),
      );
      return ArbObjectCreation(
        key: entry.key,
        className: className,
        fields: fields,
      );
    }
    throw FormatException(
      r'Expected a "$ref" to arb_instances.json or a "name" + "properties" '
      'object in schema property ${entry.key}',
      valueMap,
    );
  }

  /// Parsea todas las [entries] de `properties`. Falla si alguna no es
  /// soportada, listando todas las claves ofensoras en un único error.
  static List<ArbSchemaCreation> fromMapEntries(
    List<MapEntry<String, dynamic>> entries,
  ) {
    final schemas = <ArbSchemaCreation>[];
    final unsupported = <String>[];
    for (final entry in entries) {
      try {
        schemas.add(ArbSchemaCreation.fromMapEntry(entry));
      } on FormatException catch (error) {
        unsupported.add(error.message);
      }
    }
    if (unsupported.isNotEmpty) {
      throw FormatException(
        'Unsupported schema properties:\n'
        '${unsupported.map((e) => '  - $e').join('\n')}',
      );
    }
    return schemas;
  }

  /// Clave del schema, que es tambien la clave del campo en el arb.
  final String key;
}
