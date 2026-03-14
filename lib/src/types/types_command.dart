import 'dart:io';

import 'package:args/args.dart';
import 'package:pokedex/src/config_props.dart';
import 'package:pokedex/src/core/app_command.dart';
import 'package:pokedex/src/types/types_api.dart';

final TypesCommand typesCommand = TypesCommand(api: TypesApi.create());

class TypesCommand extends AppCommand {
  const TypesCommand({required this.api});

  final TypesApi api;

  @override
  String get name => 'types';

  @override
  ArgParser buildParser() {
    return ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Print types usage information.',
      )
      ..addOption('name', help: 'Name of the type to look up')
      ..addOption('base-url', help: 'PokéAPI base URL')
      ..addCommand('list')
      ..addCommand('get');
  }

  @override
  void execute(ArgResults command, bool verbose) {
    if (command.wasParsed('help')) {
      print('Usage: pokedex $name (list|get) <arguments>');
      print(buildParser().usage);
      exit(0);
    }

    run(command: command, verbose: verbose)
        .then((result) {
          exit(result ? 0 : 2);
        })
        .catchError((e) {
          print('Error: $e');
          exit(2);
        });
  }

  Future<bool> run({required ArgResults command, required bool verbose}) async {
    final baseUrl = ConfigProp.baseUrl.load(command);

    if (verbose) {
      print('[VERBOSE] base-url: $baseUrl');
    }

    if (command.command?.name == 'list') {
      return _listTypes(baseUrl);
    }

    if (command.command?.name == 'get') {
      if (!command.wasParsed('name')) {
        print('Error: Missing "--name"');
        print('  Please provide a type name, e.g. --name=fire');
        return false;
      }
      return _getType(baseUrl, command.option('name')!.toLowerCase());
    }

    print('Error: Unknown subcommand. Use "list" or "get".');
    return false;
  }

  Future<bool> _listTypes(String baseUrl) async {
    final types = await api.listTypes(baseUrl: baseUrl);
    if (types == null) {
      return false;
    }

    final divider = '─' * 30;
    print('');
    print('Pokémon Types:');
    print(divider);
    for (final type in types) {
      print('  ${type['name']}');
    }
    print('');
    return true;
  }

  Future<bool> _getType(String baseUrl, String name) async {
    final data = await api.getType(baseUrl: baseUrl, name: name);
    if (data == null) {
      return false;
    }

    final typeName = data['name'] as String;
    final pokemon = data['pokemon'] as List;

    final divider = '─' * 30;
    print('');
    print('Type: ${typeName.toUpperCase()}');
    print(divider);
    print('Pokémon (${pokemon.length}):');
    for (final p in pokemon.take(20)) {
      final pokemonName = p['pokemon']['name'] as String;
      print('  $pokemonName');
    }
    if (pokemon.length > 20) {
      print('  ... and ${pokemon.length - 20} more');
    }
    print('');
    return true;
  }
}
