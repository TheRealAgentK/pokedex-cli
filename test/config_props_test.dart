import 'package:args/args.dart';
import 'package:pokedex/src/config_props.dart';
import 'package:pokedex/src/environment.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigProp', () {
    test('loads from argument', () {
      final parser = ArgParser()..addOption('base-url');
      final results = parser.parse(['--base-url=https://custom.api.com']);
      final value = ConfigProp.baseUrl.load(results);
      expect(value, 'https://custom.api.com');
    });

    test('loads from environment variable', () {
      Environment.setInstance(
        Environment(baseUrl: 'https://env.api.com'),
      );

      final parser = ArgParser()..addOption('base-url');
      final results = parser.parse([]);
      final value = ConfigProp.baseUrl.load(results);
      expect(value, 'https://env.api.com');
    });

    test('argument takes priority over environment variable', () {
      Environment.setInstance(
        Environment(baseUrl: 'https://env.api.com'),
      );

      final parser = ArgParser()..addOption('base-url');
      final results = parser.parse(['--base-url=https://arg.api.com']);
      final value = ConfigProp.baseUrl.load(results);
      expect(value, 'https://arg.api.com');
    });

    test('falls back to default value', () {
      Environment.setInstance(Environment(baseUrl: null));

      final parser = ArgParser()..addOption('base-url');
      final results = parser.parse([]);
      final value = ConfigProp.baseUrl.load(results);
      expect(value, 'https://pokeapi.co/api/v2');
    });
  });
}
