enum ArbObjectType {
  simple,
  multiChoice,
  multiChoiceReplacements,
  replacements,
  ;

  static ArbObjectType fromString(String preType) {
    if (preType.contains("multiChoiceReplacements")) {
      return multiChoiceReplacements;
    }
    if (preType.contains("multiChoice")) {
      return multiChoice;
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
  }) {
    return switch (this) {
      ArbObjectType.simple => onSimple.call(),
      ArbObjectType.multiChoice => onMultiChoice.call(),
      ArbObjectType.multiChoiceReplacements => onMultiChoiceReplacements.call(),
      ArbObjectType.replacements => onReplacements.call(),
    };
  }
}

final class ArbObjectCreation {
  final String title;
  final ArbObjectType type;

  ArbObjectCreation({required this.title, required this.type});

  factory ArbObjectCreation.fromMap(Map<String, dynamic> json) {
    final String preType =
        (json.values.first as Map<String, dynamic>)["\$ref"] as String;

    return ArbObjectCreation(
        title: json.keys.first, type: ArbObjectType.fromString(preType));
  }
}
