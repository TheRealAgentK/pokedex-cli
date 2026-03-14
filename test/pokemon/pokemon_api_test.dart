import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex/src/pokemon/pokemon_api.dart';
import 'package:test/test.dart';

void main() {
  group('PokemonApi', () {
    test('getPokemon returns parsed data on success', () async {
      final mockClient = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://pokeapi.co/api/v2/pokemon/pikachu',
        );
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
      expect(result['id'], 25);
    });

    test('getPokemon returns null on 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final api = PokemonApi(httpClient: mockClient);
      final result = await api.getPokemon(
        baseUrl: 'https://pokeapi.co/api/v2',
        name: 'fakemon',
      );

      expect(result, isNull);
    });

    test('getPokemon returns null on exception', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      final api = PokemonApi(httpClient: mockClient);
      final result = await api.getPokemon(
        baseUrl: 'https://pokeapi.co/api/v2',
        name: 'pikachu',
      );

      expect(result, isNull);
    });
  });
}
