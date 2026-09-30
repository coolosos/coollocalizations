import '../../utilities/json_decoder.dart';

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

  T resolve<T>({
    required T Function() onSimple,
    required T Function() onMultiChoice,
    required T Function() onMultiChoiceReplacements,
    required T Function() onReplacements,
    required T Function() onReplacementsList,
    required T Function() onList,
  }) {
    return switch (this) {
      ArbObjectType.simple => onSimple.call(),
      ArbObjectType.multiChoice => onMultiChoice.call(),
      ArbObjectType.multiChoiceReplacements => onMultiChoiceReplacements.call(),
      ArbObjectType.replacements => onReplacements.call(),
      ArbObjectType.replacementsList => onReplacementsList.call(),
      ArbObjectType.list => onList.call(),
    };
  }

  String get dartType => switch (this) {
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

  final ArbObjectType type;

  @override
  String dartType({required bool isForMerge}) =>
      '${type.dartType}${isForMerge ? '?' : ''}';
}

final class ArbObjectCreation extends ArbSchemaCreation {
  const new({
    required super.key,
    required this.className,
    required this.fields,
  });

  /// Nombre de la clase Dart generada, tomado del `name` del schema.
  final String className;

  final List<ArbSchemaCreation> fields;

  @override
  String dartType({required bool isForMerge}) =>
      '$className${isForMerge ? '?' : ''}';
}

sealed class ArbSchemaCreation {
  const new({required this.key});

  String dartType({required bool isForMerge});

  static ArbSchemaCreation? fromMapEntry(MapEntry<String, dynamic> entry) {
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
      final fields = <ArbSchemaCreation>[];
      for (final schema in properties.entries) {
        if (ArbSchemaCreation.fromMapEntry(schema) case final field?) {
          fields.add(field);
        }
      }
      return ArbObjectCreation(
        key: entry.key,
        className: className,
        fields: fields,
      );
    }
    return null;
  }

  /// Clave del schema, que es tambien la clave del campo en el arb.
  final String key;
}
