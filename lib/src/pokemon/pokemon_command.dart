import 'dart:io';

import 'package:args/args.dart';
import 'package:pokedex/src/core/app_command.dart';

final PokemonCommand pokemonCommand = PokemonCommand();

class PokemonCommand extends AppCommand {
  const PokemonCommand();

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
      ..addOption('name', help: 'Name of the Pokémon to look up');
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

    final pokemonName = command.option('name')!;
    print('Looking up: $pokemonName');
    print('(API integration coming in the next step!)');
  }
}
