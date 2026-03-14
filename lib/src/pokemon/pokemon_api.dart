import 'dart:convert';

import 'package:http/http.dart' as http;

class PokemonApi {
  const PokemonApi({required this.httpClient});

  PokemonApi.create() : httpClient = http.Client();

  final http.Client httpClient;

  /// Fetches a Pokémon by name from PokéAPI.
  /// Returns the parsed JSON map, or null on failure.
  Future<Map<String, dynamic>?> getPokemon({
    required String baseUrl,
    required String name,
  }) async {
    final url = '$baseUrl/pokemon/$name';

    try {
      final response = await httpClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      if (response.statusCode == 404) {
        print('Pokémon not found: $name');
        return null;
      }

      print('Error fetching Pokémon: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Exception while fetching Pokémon: $e');
      return null;
    }
  }
}
