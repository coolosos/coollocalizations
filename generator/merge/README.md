# ARB MERGES

This generator take a current arb localizations following the define schemas and merge data between then. The main idea is create a global localization by languaje that each flavour will change the value it's necessary. Insted of have each flavour time duplicate the same key value schemas.

## Example
The json base will be something like this:
```json
{
    "$schema": "schemas/array_localizations.json",
    "localizations": [
        {
            "$schema": "languaje_localizations.json",
            "locale": "es",
            "hello_world": "Hello word",
            "flavour_name": "Cool Localizations"
        }
    ]
}
```
The modification json will be something like this: (locale must be always set)
```json
{
    "localizations": [
        {
            "locale": "es",
            "flavour_name": "Mithos 5r Flavour",
            "flavour_custom":"Added new key"
        }
    ]
}
```
Result json will be:
```json
{
    "$schema": "schemas/array_localizations.json",
    "localizations": [
        {
            "$schema": "language_localizations.json",
            "locale": "es",
            "hello_world": "Hello word",
            "flavour_name": "Mithos 5r Flavour",
            "flavour_custom":"Added new key"
        }
    ]
}
```

# How to use
    -  curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://github.com/coolosos/coollocalizations/releases/download/0.0.2/arb_merges

### Compilation

- dart compile exe main.dart -o arb_merges   
