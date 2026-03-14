# Building a CLI Tool with Dart — Step-by-Step Tutorial

## CodeCamp Wellington 2026

This repo is the companion code for the talk **"Beyond Mobile: Building Production CLI Tools with Dart"**.

Each step is tagged so you can jump between them during the demo:

```bash
git checkout step-1    # Project scaffolding
git checkout step-2    # Command pattern
git checkout step-3    # Configuration (args + env vars)
git checkout step-4    # HTTP client with dependency injection
git checkout step-5    # File operations
git checkout step-6    # Second command & request builder
git checkout step-7    # Testing
git checkout step-8    # Production polish & compilation
```

The tool we're building is **`pokedex`** — a CLI that queries the free [PokéAPI](https://pokeapi.co/) to look up Pokémon data.

---

## Step 1: Project Scaffolding

**Tag:** `step-1`

**What we build:** A Dart CLI that handles `--help`, `--version`, and `--verbose` flags.

### Key files

- `pubspec.yaml` — Project definition with `args` as the only dependency
- `bin/pokedex.dart` — Entrypoint with `ArgParser`

### Demo commands

```bash
dart run bin/pokedex.dart --help
dart run bin/pokedex.dart --version
dart compile exe bin/pokedex.dart -o pokedex
```

### What to talk about

- Dart's `pubspec.yaml` is the equivalent of `package.json` or `go.mod`
- The `executables` field maps the installed binary name
- The `args` package is maintained by the Dart team — zero transitive dependencies
- `dart compile exe` produces a self-contained binary (no Dart SDK needed on the target machine)

### Key code

```dart
ArgParser buildParser() {
  return ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false,
        help: 'Print this usage information.')
    ..addFlag('verbose', abbr: 'v', negatable: false,
        help: 'Show additional command output.')
    ..addFlag('version', negatable: false,
        help: 'Print the tool version.');
}
```

---

## Step 2: The Command Pattern

**Tag:** `step-2`

**What we build:** An abstract `AppCommand` base class and the first `pokemon` command.

### Key files

- `lib/src/core/app_command.dart` — Abstract base class
- `lib/src/pokemon/pokemon_command.dart` — First command
- `lib/pokedex.dart` — Barrel export

### Demo commands

```bash
dart run bin/pokedex.dart --help          # Shows "pokemon" in command list
dart run bin/pokedex.dart pokemon --help  # Shows pokemon-specific help
dart run bin/pokedex.dart pokemon --name=pikachu  # Prints placeholder
```

### What to talk about

- The abstract class defines a contract: `name`, `buildParser()`, `execute()`
- Each command is self-contained — it owns its own argument parser
- The entrypoint routes based on `results.command?.name`
- Adding a new command means: create a class, register it in the entrypoint. That's it.

### Key code

```dart
abstract class AppCommand {
  const AppCommand();

  String get name;
  void execute(ArgResults command, bool verbose);
  ArgParser buildParser();
}
```

---

## Step 3: Configuration (Args + Env Vars)

**Tag:** `step-3`

**What we build:** A `ConfigProp` class that resolves config from CLI args, env vars, or defaults.

### Key files

- `lib/src/config_props.dart` — Config resolution logic
- `lib/src/environment.dart` — Testable environment variable wrapper

### Demo commands

```bash
# Uses default (https://pokeapi.co/api/v2)
dart run bin/pokedex.dart pokemon --name=pikachu

# Explicit argument overrides default
dart run bin/pokedex.dart -v pokemon --name=pikachu --base-url=https://custom.api.com

# Environment variable overrides default
export POKEDEX_BASE_URL=https://env.api.com
dart run bin/pokedex.dart -v pokemon --name=pikachu
unset POKEDEX_BASE_URL
```

### What to talk about

- Resolution order: CLI argument → environment variable → default value
- This is the pattern CI/CD pipelines expect (set secrets as env vars)
- `Environment` is a wrapper around `Platform.environment` with `setInstance()` for testing
- No real env vars leak into tests

### Key code

```dart
String load(ArgResults arguments) {
  String? value;
  if (arguments.wasParsed(name)) {
    value = arguments[name];
  } else {
    value = Environment.instance[envKey];
  }
  value ??= defaultValue;
  if (value == null) {
    print('Error: Missing "$name"');
    exit(2);
  }
  return value;
}
```

---

## Step 4: HTTP Client with Dependency Injection

**Tag:** `step-4`

**What we build:** A real API call to PokéAPI with the HTTP client injected via constructor.

### Key files

- `lib/src/pokemon/pokemon_api.dart` — API client with DI
- Updated `pokemon_command.dart` — Uses the API, displays formatted output

### Demo commands

```bash
dart run bin/pokedex.dart pokemon --name=pikachu
dart run bin/pokedex.dart pokemon --name=charizard
dart run bin/pokedex.dart pokemon --name=doesnotexist
```

### What to talk about

- `PokemonApi` accepts `http.Client` via constructor → testable
- `PokemonApi.create()` factory → production use with a real client
- This is the same DI pattern used in the Raygun CLI — no framework needed
- The API client returns `Map<String, dynamic>?` — null means failure
- `dart:convert` handles JSON parsing — no third-party serialization library needed

### Key code

```dart
class PokemonApi {
  const PokemonApi({required this.httpClient});
  PokemonApi.create() : httpClient = http.Client();

  final http.Client httpClient;

  Future<Map<String, dynamic>?> getPokemon({
    required String baseUrl,
    required String name,
  }) async {
    final response = await httpClient.get(Uri.parse('$baseUrl/pokemon/$name'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
```

---

## Step 5: File Operations

**Tag:** `step-5`

**What we build:** An `--output` flag that saves Pokémon data to a JSON file.

### Key files

- Updated `pokemon_command.dart` — adds `--output` option and `_saveToFile()`

### Demo commands

```bash
dart run bin/pokedex.dart pokemon --name=eevee --output=eevee.json
cat eevee.json | head -20
```

### What to talk about

- `dart:io`'s `File` class handles all file operations
- `JsonEncoder.withIndent('  ')` pretty-prints JSON
- `File.writeAsStringSync()` for simple writes — no third-party packages needed
- Dart's standard library covers file I/O, JSON, paths, platform detection

### Key code

```dart
void _saveToFile(Map<String, dynamic> data, String path) {
  final file = File(path);
  final encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync(encoder.convert(data));
  print('Saved to: $path');
}
```

---

## Step 6: Second Command & Request Builder

**Tag:** `step-6`

**What we build:** A `types` command with subcommands (`list`, `get`) and a request builder.

### Key files

- `lib/src/core/request_builder.dart` — Builder pattern for HTTP requests
- `lib/src/types/types_api.dart` — Second API client
- `lib/src/types/types_command.dart` — Second command with subcommands

### Demo commands

```bash
dart run bin/pokedex.dart --help         # Now shows both "pokemon" and "types"
dart run bin/pokedex.dart types list
dart run bin/pokedex.dart types get --name=fire
dart run bin/pokedex.dart types get --name=dragon
```

### What to talk about

- The architecture scales — same pattern, same shape, new module
- `ArgParser.addCommand()` gives us subcommands (`list`, `get`)
- The request builder keeps HTTP construction readable and chainable
- Adding a second command required zero changes to the core — just a new module and one line in the entrypoint

### Key code

```dart
// Builder pattern
final request = GetRequestBuilder('$baseUrl/type/$name')
    .acceptJson()
    .build();

// Subcommand routing
if (command.command?.name == 'list') {
  return _listTypes(baseUrl);
}
if (command.command?.name == 'get') {
  return _getType(baseUrl, name);
}
```

---

## Step 7: Testing

**Tag:** `step-7`

**What we build:** Tests for config, API clients, and commands using mocked HTTP.

### Key files

- `test/config_props_test.dart` — Config resolution tests
- `test/pokemon/pokemon_api_test.dart` — API client tests
- `test/pokemon/pokemon_command_test.dart` — Command integration tests
- `test/types/types_command_test.dart` — Types command tests

### Demo commands

```bash
dart test
```

### What to talk about

- 13 tests covering config resolution, API success/failure, and command orchestration
- `package:http/testing.dart` provides `MockClient` — mock HTTP at the boundary
- DI makes testing natural: pass a mock client, test the logic
- `Environment.setInstance()` prevents tests from depending on real env vars
- No build_runner step needed for these tests (MockClient is simpler than mockito code gen for this use case)
- For more complex projects, `mockito` + `build_runner` generates mock classes (as in Raygun CLI)

### Key code

```dart
test('getPokemon returns parsed data on success', () async {
  final mockClient = MockClient((request) async {
    expect(request.url.toString(),
        'https://pokeapi.co/api/v2/pokemon/pikachu');
    return http.Response(
      '{"id": 25, "name": "pikachu", "height": 4, "weight": 60}',
      200,
    );
  });

  final api = PokemonApi(httpClient: mockClient);
  final result = await api.getPokemon(
    baseUrl: 'https://pokeapi.co/api/v2',
    name: 'pikachu',
  );

  expect(result, isNotNull);
  expect(result!['name'], 'pikachu');
});
```

---

## Step 8: Production Polish & Distribution

**Tag:** `step-8`

**What we build:** Clean analysis, formatted code, and a compiled binary.

### Demo commands

```bash
# Full CI checks — same as what you'd run in GitHub Actions
dart format --set-exit-if-changed .
dart analyze
dart test

# Compile to native binary
dart compile exe bin/pokedex.dart -o pokedex

# Run the binary — no Dart SDK needed
./pokedex pokemon --name=mew
./pokedex types get --name=ghost

# Show binary size
ls -lh pokedex    # ~7 MB
```

### What to talk about

- The full CI check is three commands: `format`, `analyze`, `test`
- `dart compile exe` produces a ~7 MB self-contained binary
- Exit codes: 0 (success), 1 (operation failed), 2 (error/invalid input)
- The binary runs on any machine of the same OS/arch — no runtime needed
- For cross-platform distribution, use GitHub Actions with runners for Linux, macOS, and Windows
- Reference the Raygun CLI's `release.yml` workflow for the real-world CI setup

### Exit code pattern

```dart
run(command: command, verbose: verbose).then((result) {
  exit(result ? 0 : 2);
}).catchError((e) {
  print('Error: $e');
  exit(2);
});
```

---

## Architecture Summary

```
bin/pokedex.dart (entrypoint)
    │
    ├── Parses global flags: --help, --verbose, --version
    │
    └── Routes to commands:
        ├── PokemonCommand → PokemonApi → pokeapi.co/api/v2/pokemon/{name}
        └── TypesCommand   → TypesApi   → pokeapi.co/api/v2/type/{name}
```

### Dependency Graph

| Layer | Purpose | Example |
|-------|---------|---------|
| **Entrypoint** | Arg parsing, routing | `bin/pokedex.dart` |
| **Command** | Orchestration, validation | `PokemonCommand`, `TypesCommand` |
| **Config** | Arg + env var resolution | `ConfigProp`, `Environment` |
| **API Client** | HTTP calls, response handling | `PokemonApi`, `TypesApi` |
| **Core** | Shared abstractions | `AppCommand`, `GetRequestBuilder` |

### Runtime Dependencies

| Package | Purpose |
|---------|---------|
| `args` | CLI argument parsing |
| `http` | HTTP client |

That's it. Everything else comes from Dart's standard library.

---

## Quick Reference

```bash
# Switch between steps
git checkout step-1 && dart pub get
git checkout step-2 && dart pub get
# ...
git checkout step-8 && dart pub get

# Run the CLI
dart run bin/pokedex.dart pokemon --name=pikachu

# Run tests (step-7+)
dart test

# Compile (any step)
dart compile exe bin/pokedex.dart -o pokedex

# Clean up
rm -f pokedex *.json
```
