# ARB CREATION

This generator take a current arb json schema how define all the localizations properties and generate a dart class with all the required method and update the json schema for be sure that all keys are required.

## Example
The json base will be something like this:
```json
{
  "$schema": "https://raw.githubusercontent.com/coolosos/coollocalizations/main/json_schemas/arb_localization.json",
  "title": "Localization",
  "description": "Localization finetwork schema",
  "type": "object",
  "properties": {
    "locale": {
      "$ref": "https://raw.githubusercontent.com/coolosos/coollocalizations/main/json_schemas/arb_instances.json#/objects/simple"
    },
    "hello_world": {
      "$ref": "https://raw.githubusercontent.com/coolosos/coollocalizations/main/json_schemas/arb_instances.json#/objects/simple"
    },
    "remplazable_object": {
      "$ref": "https://raw.githubusercontent.com/coolosos/coollocalizations/main/json_schemas/arb_instances.json#/objects/replacement"
    },
  }
}
```
After execution the json will be like:
```json
{
  "$schema": "https://raw.githubusercontent.com/coolosos/coollocalizations/main/json_schemas/arb_localization.json",
  "title": "Localization",
  "description": "Localization finetwork schema",
  "type": "object",
  "properties": {
    "locale": {
      "$ref": "https://raw.githubusercontent.com/coolosos/coollocalizations/main/json_schemas/arb_instances.json#/objects/simple"
    },
    "hello_world": {
      "$ref": "https://raw.githubusercontent.com/coolosos/coollocalizations/main/json_schemas/arb_instances.json#/objects/simple"
    },
    "remplazable_object": {
      "$ref": "https://raw.githubusercontent.com/coolosos/coollocalizations/main/json_schemas/arb_instances.json#/objects/replacement"
    },
  },
  "required": [
    "locale",
    "hello_world",
    "remplazable_object",
    ]
}
```
And the dart generate class will be something like: 
```dart
@JsonSerializable()
final class ArbLocalizations {
  const ArbLocalizations({required this.localizations});

  factory ArbLocalizations.fromFile(String file) {
    return _$ArbLocalizationsFromJson(json.decode(file));
  }

  final List<LanguajeLocalization> localizations;
}
@JsonSerializable()
class LanguajeLocalization {
  const LanguajeLocalization(
      {required this.locale,
      required this.hello_world,
      required this.remplazable_object,});
...
}

```

One time the files are create you must create your localization class with all the languajes as:

```json
{
    "$schema": "schemas/array_localizations.json",
    "localizations": [
        {
            "$schema": "languaje_localizations.json",
            "locale": "es",
            "hello_world": "Hello World",
            "remplazable_object": {
                "value": "Hello {name}"
            },
        }
    ]
}
```

This file.json can be remote or locale if it's locale and you are using Flutter this file must be in your assets for reading by:

```dart
class ReadJsonAssetFile {
  const ReadJsonAssetFile({
    required this.arbFilePath,
  });

  final String arbFilePath;

  Future<ArbLocalizations> loadLanguajes() async {
    final availableLenguajes = await rootBundle.loadString(arbFilePath);

    final lenguajesAvailables = ArbLocalizations.fromFile(availableLenguajes);

    return lenguajesAvailables;
  }
}
```

# How to use
    -  curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://github.com/coolosos/coollocalizations/releases/download/0.0.2/arb_creation

### Compilation

- dart compile exe main.dart -o arb_creation 