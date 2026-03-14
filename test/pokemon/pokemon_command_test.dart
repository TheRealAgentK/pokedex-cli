import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex/src/environment.dart';
import 'package:pokedex/src/pokemon/pokemon_api.dart';
import 'package:pokedex/src/pokemon/pokemon_command.dart';
import 'package:test/test.dart';

const samplePokemonJson = '''
{
  "id": 25,
  "name": "pikachu",
  "height": 4,
  "weight": 60,
  "types": [{"slot": 1, "type": {"name": "electric"}}],
  "stats": [
    {"base_stat": 35, "stat": {"name": "hp"}},
    {"base_stat": 55, "stat": {"name": "attack"}}
  ]
}
''';

void main() {
  setUp(() {
    Environment.setInstance(Environment(baseUrl: null));
  });

  group('PokemonCommand', () {
    test('run returns true on successful lookup', () async {
      final mockClient = MockClient((request) async {
        return http.Response(samplePokemonJson, 200);
      });

      final command = PokemonCommand(api: PokemonApi(httpClient: mockClient));
      final parser = command.buildParser();
      final results = parser.parse(['--name=pikachu']);

      final success = await command.run(command: results, verbose: false);
      expect(success, true);
    });

    test('run returns false when pokemon not found', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final command = PokemonCommand(api: PokemonApi(httpClient: mockClient));
      final parser = command.buildParser();
      final results = parser.parse(['--name=fakemon']);

      final success = await command.run(command: results, verbose: false);
      expect(success, false);
    });

    test('run uses custom base-url from argument', () async {
      String? capturedUrl;
      final mockClient = MockClient((request) async {
        capturedUrl = request.url.toString();
        return http.Response(samplePokemonJson, 200);
      });

      final command = PokemonCommand(api: PokemonApi(httpClient: mockClient));
      final parser = command.buildParser();
      final results = parser.parse([
        '--name=pikachu',
        '--base-url=https://custom.api.com',
      ]);

      await command.run(command: results, verbose: false);
      expect(capturedUrl, 'https://custom.api.com/pokemon/pikachu');
    });
  });
}
