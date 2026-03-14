import 'dart:io';

import 'package:args/args.dart';
import 'package:pokedex/src/environment.dart';

/// A config property that can be set via argument or environment variable.
class ConfigProp {
  static const baseUrl = ConfigProp(
    name: 'base-url',
    envKey: Environment.baseUrlKey,
    defaultValue: 'https://pokeapi.co/api/v2',
  );

  final String name;
  final String envKey;
  final String? defaultValue;

  const ConfigProp({
    required this.name,
    required this.envKey,
    this.defaultValue,
  });

  /// Load the value from arguments, environment variables, or default.
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
      print(
        '  Please provide "$name" via argument or environment variable "$envKey"',
      );
      exit(2);
    }
    return value;
  }
}
