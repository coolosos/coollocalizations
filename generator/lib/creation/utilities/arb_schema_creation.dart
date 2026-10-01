import '../../utilities/json_decoder.dart';

/// Appends the `?` suffix that the types of the merge variant carry.
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

  /// Dart type a reference of this type points to, without nullability.
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

  /// Type the schema property points to.
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

  /// Name of the generated Dart class, taken from the schema `name`.
  final String className;

  /// Properties of the object, which are emitted in their own division class.
  final List<ArbSchemaCreation> fields;

  @override
  String dartType({required bool isForMerge}) =>
      _nullableType(className, isForMerge);
}

sealed class ArbSchemaCreation {
  const new({required this.key});

  /// Type the property is declared with in the generated class.
  String dartType({required bool isForMerge});

  /// Parses a single properties entry of the schema.
  ///
  /// Throws [FormatException] if the entry is not supported.
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

  /// Parses every [entries] of `properties`. Fails if any of them is not
  /// supported, listing all the offending keys in a single error.
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

  /// Schema key, which is also the field key in the arb.
  final String key;
}
