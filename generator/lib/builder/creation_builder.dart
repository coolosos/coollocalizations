import 'dart:async';

import 'package:build/build.dart';

import 'creation_main.dart';

Builder creationBuilder(BuilderOptions options) {
  return CreationBuilder(config: options.config);
}

final class CreationBuilder extends Builder {
  CreationBuilder({required this.config});

  final Map<String, dynamic> config;

  @override
  FutureOr<void> build(BuildStep buildStep) {
    final arguments = config.entries
        .map(
      (e) => [e.key, e.value.toString()],
    )
        .fold(
      <String>[],
      (previousValue, element) => previousValue..addAll(element),
    );
    creation(arguments);
  }

  @override
  Map<String, List<String>> get buildExtensions => {};
}
