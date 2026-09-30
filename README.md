# coollocalizations
Manage localizations for internationalization

# 🌍 Localization Management Scripts Documentation

## 📝 Overview

This document outlines the basic structure and workflow for the custom **creation**, **merge** and **check** scripts used to manage application localization (l10n).

The primary goal of these scripts is to:
1. **Generate** necessary localization files (like Dart classes and schemas) from base configuration files.
2. **Merge** project-specific modifications with the base localization file (`arb.json`).
3. **Check** that the base ARB file stays in sync with the schema.

All file names and paths mentioned below are examples and **can be modified** by adjusting the script parameters accordingly.

---

## 📋 Requirements

| Requirement | Version |
| :--- | :--- |
| Dart SDK | `>=3.13.2 <4.0.0` |

The generator uses modern Dart language features (`const new`, `factory fromJson`, pattern
matching) that require Dart 3.13 or newer.

All three packages in this repository share the same lint configuration, based on
[`coolint`](https://pub.dev/packages/coolint) `^3.0.0`. Run the linter with:

```bash
dart analyze
```

---

## ⚙️ Initial Setup: Schema and Template Files

Before running any script, the user must create the following template files. These files define the structure, languages, and specific modifications for the localization process.

### 📁 Generators Directory (`./example/lib/generators/`)

| File Name | Purpose | Used as Schema for |
| :--- | :--- | :--- |
| `arb.json` | **Base ARB File:** Contains all localization keys and default texts. | - |
| `language_localizations.json` | Defines the structure of a language and its text keys. **It's the primary source of truth for all required keys.** | Used by the creation script to generate Dart files. |

### 📁 Schemas Directory (`./example/lib/schemas/`)

| File Name | Purpose | Used as Schema for |
| :--- | :--- | :--- |
| `array_localizations.json` | **ARB Schema:** Used as the schema for `arb.json` to ensure all necessary language keys are present and prevent missing keys (warnings/errors in development tools). | `arb.json` |
| `modification_localizations.json` | **Merge Schema:** Defines the structure for the `arb_merge.json` file, allowing developers to specify partial or complete changes by language. | `arb_merge.json` |

Every script exposes its own usage information:

```bash
dart run generator/bin/creation_arb.dart help
dart run generator/bin/merge_arb.dart help
dart run generator/bin/checker_non_required_arb.dart help
dart run generator/bin/checker_non_used_arb.dart help
```

---

## 🚀 Phase 1: File Generation (The Creation Script)

The first step is to generate the necessary supporting files (Dart classes, schemas) used throughout the project.

### 1. Execute the Creation Script

Run the following command from the appropriate directory:

```bash
dart run generator/bin/creation_arb.dart  -s ./example/lib/generators/language_localizations.json  -n ./example/lib/gen/arb_localizations  -m ./example/lib/gen/modification_schema.json
```

| Parameter | Description |
| :--- | :--- |
| `-s` | Path to the source file (`language_localizations.json`). |
| `-n` | **Output name/path** for the generated Dart localization classes (e.g., `./example/lib/gen/arb_localizations` will generate `arb_localizations.dart`, etc.). Missing directories are created automatically. |
| `-m` | **Output path** for the generated modification schema file (`modification_schema.json`). |
| `-c` | Optional directory where the resulting schema is copied as `localization_schema.json`. The directory is created if missing. |

### 2. Run Code Generation (JsonSerializable)

After executing the creation script, you must generate the boilerplate code for `JsonSerializable` using the Dart build runner:

```bash
dart run build_runner build
```

> `build_runner` `^2.16.1` removed the `--delete-conflicting-outputs` flag, so it must not be
> passed anymore.

### 3. Generated Artifacts

Upon successful execution, the following files will be generated/modified within the `./example/lib/gen/` directory:

* **`arb_localizations_divisions`**: Contains class divisions (e.g., if localization keys are grouped).
* **`arb_localizations_merge.dart`**: The file used for potentially modifying localization information remotely (e.g., dynamic updates).
* **`arb_localizations.dart`**: Contains the final Dart classes with all localization keys from the base file.
* **`modification_schema.json`**: A modified version of `language_localizations.json` *without* required fields. This acts as the schema for merge files.
* **Modification to `language_localizations.json`**: This file is updated to include all required fields for its objects, ensuring that `arb.json` triggers warnings if any text key is missing.

---

## 🔄 Phase 2: Localization Merging (The Merge Script)

The merge script allows for modification of the base `arb.json` output, which is especially useful when multiple applications share the same base keys but require partial or complete changes to some values.

### 1. Merge Directory Setup (`./example/lib/merge/`)

| File Name | Generation Method | Purpose |
| :--- | :--- | :--- |
| `arb_merge.json` | **Manually Created** | Uses the `modification_localizations.json` schema. Specifies the changes for the base ARB file, typically defined per language. |
| `arb_after_merge.json` | **Automatically Generated** | The final output file containing the merged localization data for the specific application. **Do NOT create this file manually.** |

> **⚠️ Recommendation:** It is strongly recommended to **ignore** the `arb_merge.json` file in Git and `pubspec.yaml`, and only commit the automatically generated `arb_after_merge.json` to the repository.

### 2. Execute the Merge Script

After defining the necessary changes in `arb_merge.json`, run the script:

```bash
dart run generator/bin/merge_arb.dart  -a ./example/lib/generators/arb.json  -m ./example/lib/merge/arb_merge.json  -o ./example/lib/merge/arb_after_merge.json  --typology localization
```

| Parameter | Description |
| :--- | :--- |
| `-a` | Path to the **Base ARB file** (`arb.json`). |
| `-m` | Path to the **Modification file** (`arb_merge.json`). |
| `-o` | Path to the **Output file** (`arb_after_merge.json`). |
| `--typology` | The type of merge being performed: `localization` or `any` (default). |
| `-r` | Optional list of global word replacements with the format `word:replacement,other:otherReplacement`. Applied to the whole output, and malformed pairs are reported and skipped. |

### 3. Final Output

The execution of the merge script generates the `arb_after_merge.json` file. This is the final localization file that will be consumed by the specific application, typically placed in the `assets/l10n` directory of the consuming app.

---

## ✅ Phase 3: Consistency Checks

Two additional scripts validate that the base ARB file and the code stay in sync with
`language_localizations.json`. Both exit with code `1` when they find problems, so they can be
wired into CI.

### 1. Keys used in code

Reports the schema keys that are never read in the given source directory:

```bash
dart run generator/bin/checker_non_used_arb.dart  -a ./example/lib/generators/language_localizations.json  -o ./example/lib/checks/non_used  -s ./example/lib
```

| Parameter | Description |
| :--- | :--- |
| `-a` | Path to the schema (`language_localizations.json`). |
| `-o` | **Output path** for the report of unused keys. |
| `-s` | Directory that is recursively scanned looking for `.<key>` accesses. |

### 2. Keys required by the schema

Reports the keys present in `arb.json` but missing from the schema:

```bash
dart run generator/bin/checker_non_required_arb.dart  -a ./example/lib/generators/language_localizations.json  -o ./example/lib/checks/non_required  -s ./example/lib/generators/arb.json
```

| Parameter | Description |
| :--- | :--- |
| `-a` | Path to the schema (`language_localizations.json`). |
| `-o` | **Output path** for the report of keys that are not required. |
| `-s` | Path to the base ARB file (`arb.json`). |

Both reports are written as valid, indented JSON, for example:

```json
{
  "result": [
    {
      "locale": "es",
      "non_requires": [
        "welcomeMessage"
      ]
    }
  ]
}
```

---

## 🛠️ Project Integration (Dart/Flutter)

To use these scripts in your Dart or Flutter project, you must first add the necessary development dependencies to your `pubspec.yaml` file.

### 1. Add Dependencies to `pubspec.yaml`

Include the following dependencies under the `dependencies` and `dev_dependencies` section. This configures the project to use `build_runner` and fetches the `coollocalizations_generator` package directly from the Git repository.

```yaml
environment:
  sdk: ">=3.13.2 <4.0.0"

dependencies:
  coollocalizations: # Brings you the generated classes that you will need in your Dart/Flutter project
    git:
      url: git@github.com:coolosos/coollocalizations.git
      ref: latest # Use 'latest' or a specific commit/branch

dev_dependencies:
  build_runner: ^2.16.1 # Required for code generation like JsonSerializable
  json_serializable: ^6.14.1 # Required for code generation
  coollocalizations_generator:
    git:
      url: git@github.com:coolosos/coollocalizations.git
      path: generator
      ref: latest # Use 'latest' or a specific commit/branch
```

After modifying the file, run `dart pub get` (or `flutter pub get`) in your terminal.

### 2. Execution via Dart Runner

Once the dependency is installed, you can execute the scripts directly using the package name (`coollocalizations_generator`) followed by the specific executable (e.g., `creation_arb` or `merge_arb`).

| Script Name | Command (Simplified) |
| :--- | :--- |
| **Creation** | `dart run coollocalizations_generator:creation_arb [options]` |
| **Merge** | `dart run coollocalizations_generator:merge_arb [options]` |
| **Non required check** | `dart run coollocalizations_generator:checker_non_required_arb [options]` |
| **Non used check** | `dart run coollocalizations_generator:checker_non_used_arb [options]` |

This setup ensures that the scripts are run using the path defined in your project dependencies, simplifying the execution commands compared to using relative paths (`../generator/bin/creation_arb.dart`).

### 3. Lint configuration

Add the same preset used across this repository so generated code stays lint clean:

```yaml
include: package:coolint/dart.yaml
```

> The `coollocalizations_generator` package is a CLI, so it disables `avoid_print` in its own
> `analysis_options.yaml`.
