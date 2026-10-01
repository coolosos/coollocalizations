# ARB CREATION

Este generador toma un JSON Schema que describe la estructura de localizaciones (`language_localizations.json`) y genera:

- Clases Dart tipadas para leer los ARB/JSON en runtime: `LanguageLocalization` (estricto) y `LanguageLocalizationMerge` (laxo para merges parciales).
- Divisiones en clases extra cuando una propiedad es un objeto inline con `name` + `properties`.
- Dos versiones del schema: una con todos los campos requeridos (para validar el ARB completo) y otra con `required: []` (para merges parciales).

## El truco: dos schemas con `required` opuestos

La ejecución modifica el schema de entrada in-place para producir dos salidas:

| Schema | `required` | Uso |
| :--- | :--- | :--- |
| `language_localizations.json` (reescrito) | Todas las claves | Usado por herramientas/editores para detectar textos faltantes en `arb.json`. |
| `modification_schema.json` (`-m`) | `[]` | Schema para archivos de merge (`arb_merge.json`), permitiendo cambios parciales por idioma. |

`creation_arb.dart` hace lo siguiente en orden: genera las dos clases Dart en paralelo, luego crea la copia de merge (vacía de requeridos) y finalmente vuelve a poblar `required` con todas las claves en el schema original.

## Formas de propiedad admitidas

Cada propiedad dentro de `properties` debe seguir una de estas formas:

1. **Referencia a tipos predefinidos** (`arb_instances.json`):  
   ```json
   "hello_world": {
     "$ref": "https://raw.githubusercontent.com/coolosos/coollocalizations/main/json_schemas/arb_instances.json#/objects/simple"
   }
   ```
2. **Objeto inline dividido (division)**:  
   ```json
   "loginL10n": {
     "name": "LoginLocalizationArb",
     "properties": { ... },
     "type": "object",
     "required": [ ... ]
   }
   ```

Si una propiedad no cumple ninguna, el generador lanza `FormatException` listando todas las claves no soportadas (fail-loud). No se descartan propiedades silenciosamente.

### Mapeo `$ref` → tipos Dart

El tipo se determina por el `$ref` (coincidencia por substring, con prioridad correcta):

| `$ref` contiene | Tipo Dart (base) | Notas |
| :--- | :--- | :--- |
| `multiChoiceReplacements` | `MultiChoiceReplacementsLocalizations` | Comprobar antes que `multiChoice`. |
| `multiChoice` | `MultiChoiceLocalizations` | Plural/multi-opción. |
| `replacementList` | `ReplacementsListLocalizations` | Lista con reemplazos. |
| `simpleList` | `List<String>` | Lista de strings. |
| `replacement` | `ReplacementsLocalizations` | Un único valor con reemplazos. |
| Cualquier otro caso | `String` | Caso por defecto (`simple`). |

La variante **merge** añade `?` a todos los tipos (nullable) y envuelve los casts de objetos complejos en un ternario `is Map<String, dynamic>` para tolerar claves ausentes.

## Divisions

Cuando una propiedad define `name` (nombre de la clase Dart) y `properties` (mapa de subcampos), se genera una clase separada en:

```
<outputName>_divisions/<className>.dart
```

La clase padre importa y reexporta estas divisiones (solo en la variante no-merge). Cada división recibe su propio `_json` y expone getters igual que la clase principal.

## Artefactos generados

Para `-n ./example/lib/gen/arb_localizations` se generan:

- `arb_localizations.dart` — Interfaz `ArbLocalizations` y clase `LanguageLocalization` (estricta).
- `arb_localizations_merge.dart` — Interfaz `ArbLocalizationsMerge` y clase `LanguageLocalizationMerge` (laxa).
- `arb_localizations_divisions/` — Directorio con una clase por división (solo en variante estricta).
- `modification_schema.json` (`-m`) — Copia del schema con `required: []`.
- (opcional) `localization_schema.json` en `-c` — Copia del schema ya con todos los `required` poblados.

Además, el script **reescribe** `language_localizations.json` (ruta pasada en `-s`) añadiendo `required` para todas sus propiedades y normalizando los objetos inline.

## Uso

### Dentro de este repositorio

```bash
dart run generator/bin/creation_arb.dart help
dart run generator/bin/creation_arb.dart \
  -s ./example/lib/generators/language_localizations.json \
  -n ./example/lib/gen/arb_localizations \
  -m ./example/lib/gen/modification_schema.json \
  -c ./example/lib/schemas
```

### Desde un proyecto consumidor

En el proyecto que usa las localizaciones, declara la librería y el generador
como dos dependencias `git` del mismo repositorio (el generador necesita
`path: generator`):

```yaml
environment:
  sdk: ">=3.13.2 <4.0.0"

dependencies:
  coollocalizations:
    git:
      url: git@github.com:coolosos/coollocalizations.git
      ref: 0.3.4

dev_dependencies:
  coollocalizations_generator:
    git:
      url: git@github.com:coolosos/coollocalizations.git
      path: generator
      ref: 0.3.4
```

Tras `dart pub get`, el ejecutable se invoca por nombre de paquete y las rutas
son relativas a la raíz del proyecto:

```bash
dart run coollocalizations_generator:creation_arb help
dart run coollocalizations_generator:creation_arb \
  -s lib/generators/language_localizations.json \
  -n lib/gen/arb_localization \
  -m lib/gen/modification_schema.json
```

> **Mantén ambos `ref` en la misma release.** El código generado llama a los
> constructores `fromJson` que expone `coollocalizations`; si las dos
> dependencias apuntan a versiones distintas, lo más probable es un error de
> compilación justo después de generar.

### Parámetros

| Parámetro | Abreviatura | Aliases | Por defecto | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `--schema` | `-s` | — | **Obligatorio** | Ruta al schema JSON de entrada (`language_localizations.json`). |
| `--source-directory` | `-n` | — | `arb_localization` | Nombre/ruta base para los ficheros Dart generados. Se crean directorios padres si faltan. |
| `--modification-schema` | `-m` | — | `modification_schema.json` | Ruta de salida del schema de merge (sin `required`). |
| `--copy-schema-location` | `-c` | `copySchema` | — | Directorio donde copiar el schema resultante como `localization_schema.json`. |

> Nota: El nombre del parámetro `--source-directory` refleja su origen histórico, pero determina la ruta/base de salida de las clases Dart.

## Compilación/ejecución directa

Para compilar el binario:

```bash
dart compile exe generator/bin/creation_arb.dart -o arb_creation
```

Para descargar una release precompilada (ejemplo):

```bash
curl -L -o arb_creation \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://github.com/coolosos/coollocalizations/releases/download/0.0.2/arb_creation
chmod +x arb_creation
```

## Notas

- Las clases generadas incluyen cabeceras `// GENERATED CODE - DO NOT MODIFY BY HAND` y `// coverage:ignore-file`.
- En la variante no-merge se añade `updateFromMerge(LanguageLocalizationMerge merge)` para combinar cambios parciales.
- Este paquete CLI desactiva `avoid_print` en su `analysis_options.yaml` (progreso por terminal).