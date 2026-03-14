import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex/src/environment.dart';
import 'package:pokedex/src/types/types_api.dart';
import 'package:pokedex/src/types/types_command.dart';
import 'package:test/test.dart';

const sampleTypesListJson = '''
{
  "count": 2,
  "results": [
    {"name": "fire", "url": "https://pokeapi.co/api/v2/type/10/"},
    {"name": "water", "url": "https://pokeapi.co/api/v2/type/11/"}
  ]
}
''';

const sampleTypeDetailJson = '''
{
  "name": "fire",
  "pokemon": [
    {"pokemon": {"name": "charmander"}},
    {"pokemon": {"name": "charmeleon"}},
    {"pokemon": {"name": "charizard"}}
  ]
}
''';

void main() {
  setUp(() {
    Environment.setInstance(Environment(baseUrl: null));
  });

  group('TypesCommand', () {
    test('run list returns true on success', () async {
      final mockClient = MockClient((request) async {
        return http.Response(sampleTypesListJson, 200);
      });

      final command = TypesCommand(api: TypesApi(httpClient: mockClient));
      final parser = command.buildParser();
      final results = parser.parse(['list']);

      final success = await command.run(command: results, verbose: false);
      expect(success, true);
    });

    test('run get returns true on success', () async {
      final mockClient = MockClient((request) async {
        return http.Response(sampleTypeDetailJson, 200);
      });

      final command = TypesCommand(api: TypesApi(httpClient: mockClient));
      final parser = command.buildParser();
      final results = parser.parse(['get', '--name=fire']);

      final success = await command.run(command: results, verbose: false);
      expect(success, true);
    });

    test('run get returns false when type not found', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final command = TypesCommand(api: TypesApi(httpClient: mockClient));
      final parser = command.buildParser();
      final results = parser.parse(['get', '--name=faketype']);

      final success = await command.run(command: results, verbose: false);
      expect(success, false);
    });
  });
}
