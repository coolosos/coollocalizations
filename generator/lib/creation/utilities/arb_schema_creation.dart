enum ArbObjectType {
  simple,
  multiChoice,
  multiChoiceReplacements,
  replacements,
  replacementsList,
  list,
  ;

  static ArbObjectType? fromString(String? preType) {
    if (preType == null || preType.isEmpty) {
      return null;
    }
    if (preType.contains("multiChoiceReplacements")) {
      return multiChoiceReplacements;
    }
    if (preType.contains("multiChoice")) {
      return multiChoice;
    }
    if (preType.contains("replacementList")) {
      return replacementsList;
    }
    if (preType.contains("simpleList")) {
      return list;
    }
    if (preType.contains("replacement")) {
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
}

final class ArbRefCreation extends ArbSchemaCreation {
  ArbRefCreation({required super.title, required this.type});

  final ArbObjectType type;
}

final class ArbObjectCreation extends ArbSchemaCreation {
  const ArbObjectCreation({
    required super.title,
    required this.fields,
  });

  final List<ArbSchemaCreation> fields;
}

sealed class ArbSchemaCreation {
  const ArbSchemaCreation({required this.title});

  static ArbSchemaCreation? fromMapEntry(MapEntry<String, dynamic> entry) {
    final valueMap = (entry.value as Map<String, dynamic>);
    if (ArbObjectType.fromString(valueMap["\$ref"] as String?)
        case final type?) {
      final String title = entry.key;
      return ArbRefCreation(title: title, type: type);
    }

    if (valueMap["properties"] case final properties?
        when properties is Map<String, dynamic>) {
      final String className = valueMap["name"];
      final List<ArbSchemaCreation> fields = [];
      for (var schema in properties.entries) {
        if (ArbSchemaCreation.fromMapEntry(schema) case final field?) {
          fields.add(field);
        }
      }
      return ArbObjectCreation(title: className, fields: fields);
    }
    return null;
  }

  final String title;
}
