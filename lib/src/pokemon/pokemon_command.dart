import 'dart:io';

import 'package:args/args.dart';
import 'package:pokedex/src/config_props.dart';
import 'package:pokedex/src/core/app_command.dart';
import 'package:pokedex/src/pokemon/pokemon_api.dart';

final PokemonCommand pokemonCommand = PokemonCommand(
  api: PokemonApi.create(),
);

class PokemonCommand extends AppCommand {
  const PokemonCommand({required this.api});

  final PokemonApi api;

  @override
  String get name => 'pokemon';

  @override
  ArgParser buildParser() {
    return ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Print pokemon usage information.',
      )
      ..addOption('name', help: 'Name of the Pokémon to look up')
      ..addOption('base-url', help: 'PokéAPI base URL');
  }

  @override
  void execute(ArgResults command, bool verbose) {
    if (command.wasParsed('help')) {
      print('Usage: pokedex $name <arguments>');
      print(buildParser().usage);
      exit(0);
    }

    if (!command.wasParsed('name')) {
      print('Error: Missing "--name"');
      print('  Please provide a Pokémon name, e.g. --name=pikachu');
      exit(2);
    }

    run(command: command, verbose: verbose).then((result) {
      exit(result ? 0 : 2);
    }).catchError((e) {
      print('Error: $e');
      exit(2);
    });
  }

  Future<bool> run({
    required ArgResults command,
    required bool verbose,
  }) async {
    final pokemonName = command.option('name')!.toLowerCase();
    final baseUrl = ConfigProp.baseUrl.load(command);

    if (verbose) {
      print('[VERBOSE] base-url: $baseUrl');
      print('[VERBOSE] name: $pokemonName');
    }

    final data = await api.getPokemon(baseUrl: baseUrl, name: pokemonName);
    if (data == null) {
      return false;
    }

    _printPokemon(data);
    return true;
  }

  void _printPokemon(Map<String, dynamic> data) {
    final name = data['name'] as String;
    final id = data['id'] as int;
    final height = data['height'] as int;
    final weight = data['weight'] as int;
    final types = (data['types'] as List)
        .map((t) => t['type']['name'] as String)
        .join(', ');
    final stats = data['stats'] as List;

    print('');
    print('${name.toUpperCase()} (#$id)');
    print('${'─' * 30}');
    print('Type: $types');
    print('Height: ${height / 10} m');
    print('Weight: ${weight / 10} kg');
    print('');
    print('Base Stats:');
    for (final stat in stats) {
      final statName = stat['stat']['name'] as String;
      final baseStat = stat['base_stat'] as int;
      final bar = '█' * (baseStat ~/ 5);
      print('  ${statName.padRight(20)} ${'$baseStat'.padLeft(3)}  $bar');
    }
    print('');
  }
}
