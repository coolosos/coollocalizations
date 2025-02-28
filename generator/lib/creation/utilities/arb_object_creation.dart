enum ArbObjectType {
  simple,
  multiChoice,
  multiChoiceReplacements,
  replacements,
  replacementsList,
  list,
  ;

  static ArbObjectType fromString(String preType) {
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

final class ArbObjectCreation {
  ArbObjectCreation({required this.title, required this.type});

  factory ArbObjectCreation.fromMap(Map<String, dynamic> json) {
    final String preType =
        (json.values.first as Map<String, dynamic>)["\$ref"] as String;

    return ArbObjectCreation(
      title: json.keys.first,
      type: ArbObjectType.fromString(preType),
    );
  }
  final String title;
  final ArbObjectType type;
}
