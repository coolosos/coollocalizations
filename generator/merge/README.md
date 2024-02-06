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
            "$schema": "languaje_localizations.json",
            "locale": "es",
            "hello_world": "Hello word",
            "flavour_name": "Mithos 5r Flavour",
            "flavour_custom":"Added new key"
        }
    ]
}
```

# How to use
    -  curl -s https://raw.githubusercontent.com/roysubs/custom_bash/master/custom_loader.sh >tmp.sh
    -  curl -L https://github.com/yarnpkg/yarn/releases/download/v0.23.4/ya‌​rn-v0.23.4.tar.gz > yarn.tar.gz
    -  curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/releases/assets/ASSET_ID

### Compilation

- dart compile exe main.dart -o arb_merges   
